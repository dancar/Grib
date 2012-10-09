# GribConf is simply a hash which doesn't allow invalid post-review/grib options to be stored.
# It can also have a name and can be initialized directly from a file
require 'pp'
class GribConf < Hash
  attr_accessor :conf_name
  attr_accessor :parent
  VALID_OPTIONS = [
    "server",
    "target-groups",
    "target-people",
    "summary",
    "description",
    "description-file",
    "testing-done",
    "branch",
    "change-description",
    "revision-range",
    "submit-as",
    "username",
    "password",
    "parent",
    "tracking-branch",
    "repository-url",
    "diff-filename",
    "http-username",
    "http-password",
    "review-request-id"
  ].freeze

  VALID_FLAGS = [
    "new",
    "reopen",
    "guess-summary",
    "guess-description",
    "open",
    "publish",
    # "diff-only",
    "disable-proxy"
  ].freeze

  ALL_OPTIONS = (VALID_OPTIONS + VALID_FLAGS).freeze

  def [](k)
    $LOG.warn("Invalid option: #{k}") unless ALL_OPTIONS.include?(k)
    self.has_key?(k) ? super(k) : (@parent && @parent[k])
  end

  def []=(k,v)
    unless ALL_OPTIONS.include?(k)
      $LOG.warn("Invalid option: #{k} with value #{v} in grib conf: #{@conf_name}")
      return
    end
    if VALID_FLAGS.include?(k) && !v.class.name.match(/(True|False)Class/)
      $LOG.warn("Invalid boolean value: #{v} for flag: #{k} in configuration: #{@conf_name}. using #{!!v} instead")
      v = !!v
    end
    super(k,v)
  end

  def initialize(file_path_or_hash = {}, name = "Unnamed Gribdata", parent = {})
    if file_path_or_hash.is_a?(String)
      file = File.new(file_path_or_hash, "r")
      @conf_name = file.basename
      gribdata = yaml_path,YAML.load(file)
    elsif file_path_or_hash.is_a?(Hash)
      @conf_name = name
      gribdata = file_path_or_hash
    else
      $LOG.error("invalid argument type: #{file_path_or_hash.class.name}")
      return
    end

    gribdata.each do |key,value|
      self[key] = value
    end

    @parent = parent
  end

  def to_s()
    "{-GribConf #{@conf_name}: #{inspect} [parent: #{@parent && @parent.conf_name}]-}"
  end
end