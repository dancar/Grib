require "rubygems" if RUBY_VERSION < "1.9"
gem "minitest"
require File.expand_path("../../lib/grib", __FILE__)
require "minitest/autorun"
require File.expand_path("../mock_logger", __FILE__)

class TestGribConf < MiniTest::Test

  def setup
    $LOG = MockLogger.new()
  end

  def test_conf_simple
    opts = {
      "target-people" => "hello,world"
    }
    conf = GribConf.new(opts, "test")
    assert_equal("test", conf.conf_name)
    assert_equal("hello,world", conf["target-people"])
  end

  def test_conf_simples
    opts = {
      "target-people" => "hello,world",
      "parent" => "my great parent"
    }
    conf = GribConf.new(opts, "test")
    assert_equal("hello,world", conf["target-people"])
    assert_equal("my great parent", conf["parent"])
  end


  def test_conf_bad_boolean()
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

  def test_parent()
    conf = GribConf.new({
        "guess-description" => "yes please",
        "parent" => "myfirstparent"
      }, "test", {
        "parent" => "grandparent",
        "target-people" => "mybla"
      })
    assert_equal("myfirstparent", conf["parent"])
    assert_equal("mybla", conf["target-people"])
    assert_equal(true, conf["guess-description"])
    assert_equal(nil, conf["target-groups"])
  end

end