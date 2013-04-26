require 'lib/repo_interfaces/grib_repo_interface'
module GribRepoInterfaces
  class Git < GribRepoInterfaces::GribRepoInterface
    def get_data_folder
      File.join(cmd("rev-parse --show-toplevel") , ".git")
    end
    def get_current_branch
      git("symbolic-ref -q --short HEAD")
    end

    def assert_remote_aligned
      git("rev-parse HEAD") == git("rev-parse @{u}")
    end

    private
    def git(args)
      %X[git #{args}].chomp
    end
  end
end
