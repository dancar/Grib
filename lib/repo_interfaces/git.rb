require 'lib/repo_interfaces/grib_repo_interface'
module GribRepoInterfaces
  class Git < GribRepoInterfaces::GribRepoInterface
    def get_data_folder
      File.join(git("rev-parse --show-toplevel") , ".git")
    end

    def get_current_branch
      git("symbolic-ref -q --short HEAD")
    end

    def get_current_remote_branch
      head = git("symbolic-ref -q HEAD")
      git("for-each-ref --format='%(upstream:short)' #{head}")
    end

    def get_identifier(branch)
      git("rev-parse #{branch}")
    end

    private
    def git(args)
      %x[git #{args}].chomp
    end
  end
end
