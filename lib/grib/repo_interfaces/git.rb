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
      remote_branch = git("for-each-ref --format='%(upstream:short)' #{head}")

      # Try to fallback to the default "origin/my_branch" if no upstream set:
      remote_branch = "origin/#{get_current_branch}" if remote_branch.empty?
      remote_branch = false unless git("show-ref #{remote_branch}")

      remote_branch
    end

    def assert_alignment
      # get current and remote branches:
      current = get_current_branch
      remote = get_current_remote_branch

      # Assert a remote exists:
      return "Current branch '#{current}' has no remote branch" unless remote

      # Assert both branches are aligned:
      aligned = (get_identifier(current) == get_identifier(remote))
      return "Current branch '#{current}' isn't aligned with remote '#{remote}'" unless aligned

      # All right:
      return :success
    end


    private

    def get_identifier(branch)
      git("rev-parse #{branch}")
    end

    def git(args)
      %x[git #{args}].chomp
    end
  end
end
