require 'logger'
class GribLogger < Logger
  def error(*args)
    super(*args)
    throw :error_logged if level == Logger::DEBUG
    exit -1
  end
end
def make_logger()
  logger = GribLogger.new(STDOUT)
  logger.formatter = proc do |severity, dt, progname, msg|
    sev = /(ERROR|WARN)?.*/.match(severity)[1]
    sev ? sev = "** #{sev} " : sev = " "
    "*#{sev}#{msg}\n"
  end
  logger.level = Logger.const_get(ENV["LOGGING"].upcase.to_sym) rescue Logger::INFO
  logger
end
$LOG = make_logger()
