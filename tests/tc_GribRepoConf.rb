require 'lib/grib_repo_conf'
require "test/unit"
require 'tests/test_logger'
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
    $LOG = TestLogger.new()
    @file1_path = File.join(File.dirname(__FILE__),@@FILE1)
    @file1 = File.new(@file1_path, "w")
    @file1.write YAML.dump(@@DATA1)
    @file1.close()
    @file1 = File.new(@file1_path, "r")
  end

  def teardown()
    %x[rm #{@file1_path}]
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
    assert_equal "me", g.for_branch("100")["target-people"]
    assert_equal "grandparent", g.for_branch("17")["parent"]
    assert_equal "bla-group", g.for_branch("100")["target-groups"]
    assert_equal nil, g.for_branch("17")["server"]
    assert_equal nil, g.for_branch("100")["server"]


  end

  def test_general_and_new_saved_branch()
    g = GribRepoConf.new(@file1)
    assert_equal "grandparent", g["parent"]
    assert_equal "me", g["target-people"]
    assert_equal "myparent", g.get_conf("100")["parent"]
    assert_equal "bla-group", g.get_conf("100")["target-groups"]

    g["parent"] = "new_parent"
    g["target-groups"] = "new_group"
    g.for_branch("100").tap do |b|
      b["reopen"] = true
      b["parent"] = "200"
    end
    g.set("300", "parent", "500", true) # Saves the repo conf
    @file1.close()
    g2 = GribRepoConf.new(@file1_path)
    assert_equal "new_parent", g2["parent"]
    assert_equal "new_group", g2["target-groups"]
    g2.for_branch("100").tap do |b|
      assert_equal true, b["reopen"]
      assert_equal "200", b["parent"]
      assert_equal "bla-group", b["target-groups"]
    end
    assert_equal "500", g2.for_branch("300")["parent"]
    assert_equal "new_group", g2.for_branch("300")["target-groups"]

  end
end
