RSpec.describe ActiveRecord::Sequence do
  let(:sequence_name) { 'test_sequence' }
  let(:another_sequence_name) { 'another_test_sequence' }
  let(:sequence) { described_class.new(sequence_name) }
  let(:another_sequence) { described_class.new(another_sequence_name) }

  delegate :connection, to: ActiveRecord::Base

  AlreadyExist = ActiveRecord::Sequence::AlreadyExist
  CurrentValueUndefined = ActiveRecord::Sequence::CurrentValueUndefined
  NotExist = ActiveRecord::Sequence::NotExist

  def ensure_sequence_not_exists(name)
    connection.execute("DROP SEQUENCE #{name};")
  rescue ActiveRecord::StatementInvalid # rubocop:disable Lint/HandleExceptions
  end

  before do
    ensure_sequence_not_exists('test_sequence')
    ensure_sequence_not_exists('another_test_sequence')
  end

  describe '.create' do
    it 'returns created sequence' do
      sequence = described_class.create(sequence_name)
      expect(sequence.next).to eq(1)
    end

    it 'creates new sequence' do
      described_class.create(sequence_name)
      expect(sequence.next).to eq(1)
    end

    it 'creates new sequence with start value' do
      described_class.create(sequence_name, start: 42)
      expect(sequence.next).to eq(42)
    end

    it 'creates new sequence with custom positive increment' do
      described_class.create(sequence_name, increment: 3)
      expect(sequence.next).to eq(1)
      expect(sequence.next).to eq(4)
    end

    it 'creates new sequence with custom negative increment' do
      described_class.create(sequence_name, increment: -3)
      expect(sequence.next).to eq(-1)
      expect(sequence.next).to eq(-4)
    end

    it 'creates new sequence with custom minimum value' do
      described_class.create(sequence_name, min: -2, increment: -1)
      expect(sequence.next).to eq(-1)
      expect(sequence.next).to eq(-2)
      expect { sequence.next }.to raise_error(StopIteration)
    end

    it 'creates new sequence with custom maximum value' do
      described_class.create(sequence_name, max: 2)
      expect(sequence.next).to eq(1)
      expect(sequence.next).to eq(2)
      expect { sequence.next }.to raise_error(StopIteration)
    end

    it 'creates new cyclic sequence' do
      described_class.create(sequence_name, max: 2, cycle: true)
      expect(sequence.next).to eq(1)
      expect(sequence.next).to eq(2)
      expect(sequence.next).to eq(1)
    end

    it 'fails with error if sequence already exists' do
      described_class.create(sequence_name)
      expect { described_class.create(sequence_name) }.to raise_error(AlreadyExist)
    end
  end

  describe '.drop' do
    before do
      connection.execute("CREATE SEQUENCE #{sequence_name};")
    end

    it 'drops existing sequence' do
      described_class.drop(sequence_name)
      expect { sequence.next }.to raise_error(NotExist)
    end

    context 'when sequence not exists' do
      it 'fail with error' do
        expect { described_class.drop('another_test_sequence') }.to raise_error(NotExist)
      end
    end
  end

  describe '#next' do
    before do
      described_class.create(sequence_name)
      described_class.create(another_sequence_name)
    end

    it 'returns next value' do
      expect(sequence.next).to eq(1)
      expect(sequence.next).to eq(2)
    end

    it 'returns independent values for different sequences' do
      expect(sequence.next).to eq(1)
      expect(another_sequence.next).to eq(1)
    end

    context 'when called on not existing sequence' do
      it 'fails with NotExist error' do
        not_existing_sequence = described_class.new('not_existing_sequence')
        expect { not_existing_sequence.next }.to raise_error(NotExist)
      end
    end
  end

  describe '#peek' do
    before do
      described_class.create(sequence_name)
      described_class.create(another_sequence_name)
    end

    context 'when called on sequence with not defined current value' do
      it 'fails with error' do
        expect { sequence.peek }.to raise_error(CurrentValueUndefined)
      end
    end

    context 'when called on sequence with defined current value' do
      it 'returns current value' do
        sequence.next
        expect(sequence.peek).to eq(1)
      end

      it 'returns independent values for different sequences' do
        sequence.next
        another_sequence.next
        another_sequence.next

        expect(sequence.peek).to eq(1)
        expect(another_sequence.peek).to eq(2)
      end
    end

    context 'when called on not existing sequence' do
      subject { -> { not_existing_sequence.peek } }

      let(:not_existing_sequence) { described_class.new('not_existing_sequence') }

      it { is_expected.to raise_error(NotExist) }
    end
  end
end
