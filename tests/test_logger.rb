class TestLogger
  attr_accessor :last_log
  @@last_log = nil
  def warn(*args)
    @@last_log = :warn
  end
  def error(*args)
    @@last_log = :error
  end
  def clear()
    @@last_log = nil
  end
  def initialize()
    self.clear()
  end
  def self.last_log
    @@last_log
  end
end

class Test::Unit::TestCase
  def assert_last_log (type)
    assert_equal(type, TestLogger.last_log)
  end
end