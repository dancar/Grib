require "lib/grib_command_conf"
require "lib/grib_conf"
require "test/unit"
require 'tests/test_logger'
class TestGribConf < Test::Unit::TestCase
  PARENT_GRIBCONF = GribConf.new({
    "server" => "my_server",
    "target-people" => "me"
  })

  def for_command(cmd, name = "grib_command_conf_test", parent = PARENT_GRIBCONF)
    GribCommandConf.new(cmd.split(" "), name, parent)
  end

  def test_empty()
    g = for_command ""
    assert_equal "my_server", g["server"]
    assert_equal nil, g["parent"]
  end

  def test_simple()
    g = for_command "--parent my_parent"
    assert_equal "my_parent", g["parent"]
  end

  def test_override()
    g = for_command "--server=http://mygreatserver.com"
    assert_equal "http://mygreatserver.com", g["server"]
  end

  def test_many()
    g = for_command "--parent=my_grandparent --server bla.com --dont-open --guess-description"
    assert_equal "my_grandparent", g["parent"]
    assert_equal "me", g["target-people"]
    assert_equal "bla.com", g["server"]
    assert_equal false, g["open"]
    assert_equal true, g["guess-description"]
  end

  def test_option_parser()
    g = GribCommandConf.new()
    opts = {}
    g.parse("--parent=bla --server=myserver --dont-open --guess-description".split(" ")) do |k,v|
      opts[k] = v
    end
    [opts, g].each do |hash|
      assert_equal 4, hash.length
      assert_equal "bla", hash["parent"]
      assert_equal "myserver", hash["server"]
      assert_equal false, hash["open"]
      assert_equal true, hash["guess-description"]
    end
  end

  def test_uniques()
    g = for_command "--parent=bla --new"
    assert_equal true, g["new"]
  end
end
