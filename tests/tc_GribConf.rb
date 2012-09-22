require "../grib_conf"
require "test/unit"
require 'test_logger'
class TestGrib < Test::Unit::TestCase


  def setup
    $LOG = TestLogger.new()
  end

  def test_conf_simple
    opts = {
      "target-people" => "hello,world"
    }
    conf = GribConf.new(opts, :name => "test")
    assert_equal("test", conf.conf_name)
    assert_equal("hello,world", conf["target-people"])
  end
  def test_conf_simples
    opts = {
      "target-people" => "hello,world",
      "parent" => "my great parent"
    }
    conf = GribConf.new(opts, :name => "test")
    assert_equal("hello,world", conf["target-people"])
    assert_equal("my great parent", conf["parent"])
  end

  def test_conf_invalid_opt
    conf = GribConf.new({
      "invalid-op" => :bla
    }, :name => "test")
    assert_nil(conf["invalid-op"])
    assert_last_log(:warn)
  end

  def test_conf_bad_boolean
    conf = GribConf.new({
      "guess-description" => "yes please"
    })
    assert_equal(true, conf["guess-description"])
    assert_last_log(:warn)

    $LOG.clear()
    conf = GribConf.new({
      "guess-description" => nil
    })
    assert_equal(false, conf["guess-description"])
    assert_last_log(:warn)
  end

  def test_simple_from_file end

end