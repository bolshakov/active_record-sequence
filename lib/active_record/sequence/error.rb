module ActiveRecord
  class Sequence
    Error = Class.new(StandardError)
    # Sequence is already exists and thus could not be created.
    AlreadyExist = Class.new(Error)
    # To obtain current value, you have to call `#next` first.
    CurrentValueUndefined = Class.new(Error)
    # Sequence is not exists and thus could not be deleted or accessed.
    NotExist = Class.new(Error)
  end
end
