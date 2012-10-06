require 'logger'
def make_logger()
  logger = Logger.new(STDOUT)
  logger.formatter = proc do |severity, dt, progname, msg| "* #{severity == "ERROR" ? "ERROR - " : ""} #{msg}\n" end
  env_level = (ENV["LOGGING"] || "INFO").to_sym
  logger.level = Logger.constants.include?(env_level) ? Logger.const_get(env_level) : Logger::INFO
  logger
end
$LOG = make_logger()
