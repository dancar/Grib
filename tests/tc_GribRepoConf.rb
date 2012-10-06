require '../grib_repo_conf'
require "test/unit"
require 'test_logger'
require 'yaml'
class TestGribRepoConf < Test::Unit::TestCase
  @@FILE1 = "file1.yml"
  @@DATA1 = {
    "branches" => {
      "100" => {
        "parent" => "myparent",
        "target-groups" => "bla-group"
      }
    },
    "general" => {
      "parent" => "grandparent",
      "target-people" => "me"
    }
  }

  def setup()
    @file1_path = File.join(File.dirname(__FILE__),@@FILE1)
    $LOG.info("File1: #{@file1_path}")
    @file1 = File.new(@file1_path, "w")
    @file1.write YAML.dump(@@DATA1)
    @file1.close()
    @file1 = File.new(@file1_path, "r")
  end

  def test_inexistent_branch()
    g = GribRepoConf.new(@file1).get_conf(17)
    assert_equal("me", g["target-people"])
    assert_equal("grandparent", g["parent"])
  end

  def test_all()
    g = GribRepoConf.new(@file1)
    assert_equal("me", g["target-people"])
    assert_equal("grandparent", g["parent"])
  end

  def test_branch()
    g = GribRepoConf.new(@file1).get_conf("100")
    assert_equal("me", g["target-people"])
    assert_equal("myparent", g["parent"])
    assert_equal("bla-group", g["target-groups"])
  end

  def test_save_general()
    g = GribRepoConf.new(@file1)
    @file1.close
    g["parent"] = "My_new_parent"
    g.save_file
    g2 = GribRepoConf.new(@file1_path)
    assert_equal "My_new_parent", g2["parent"]
    assert_equal "me", g2["target-people"]
  end

  def test_save_branch()
    g = GribRepoConf.new(@file1)
    @file1.close
    g["parent"] = "My_new_parent"
    g.save_file
    g2 = GribRepoConf.new(@file1_path)
    assert_equal "My_new_parent", g2["parent"]
    assert_equal "me", g2["target-people"]
  end

  def test_for_branch()
    g = GribRepoConf.new(@file1)
    assert_equal "myparent", g.for_branch("100")["parent"]
    assert_equal nil, g.for_branch("100")["target-people"]
    assert_equal nil, g.for_branch("17")["parent"]
  end

  def skip_test_general_and_new_saved_branch()
    g = GribRepoConf.new(@file1)
    assert_equal "grandparent", g["parent"]
    assert_equal "me", g["target-people"]
    assert_equal "myparent", g.get_conf("100")["parent"]
    assert_equal "bla-group", g.get_conf("100")["target-groups"]
  end
end


  #   "branches" => {
  #     100 => {
  #       "parent" => "myparent",
  #       "target-groups" => "bla-group"
  #     }
  #   },
  #   "general" => {
  #     "parent" => "grandparent",
  #     "target-people" => "me"
  #   }
  # }