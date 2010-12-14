require 'rubygems' if RUBY_VERSION < '1.9'
require 'git'

module Git

  class Elements < Git::Base
    IGNORE    = 'gcignore'
    RECURSIVE = 'gcrecursive'

    def initialize( path )
      @path = path.clone
      super( { :working_directory => @path } )
      @gcfiles, @gitfiles = elements_scan
    end

    def ignored
      return @ignored if @ignored
      ignores = @gcfiles.select do | f |
        File.basename( f ) =~ /^\.#{IGNORE}$/i
      end
      @ignored = gcfiles_scan( ignores )
    end

    def folders
      return @folders if @folders
      recursives = @gcfiles.select do | f |
        File.basename( f ) =~ /^\.#{RECURSIVE}$/i
      end
      @folders = gcfiles_scan( recursives ).collect { |f| File.join f, '/' }
    end

    def files
      return @files if @files
      @files = @gitfiles.reject do | f |
        (ignored + folders).find { |i| f =~ /^#{i}/ }
      end.sort
    end


    private

    # result[0] = git-confident special files
    # result[1] = other git tracked files
    def elements_scan
      result = ls_files.keys.sort.partition do | f |
        name = File.basename( f )
        name =~ /^\.#{IGNORE}$/i or name =~ /^\.#{RECURSIVE}$/i or name =~ /^\.gitignore$/i
      end
    end

    def gcfiles_scan( files )
      files.collect do | file |
        full_path = File.expand_path( file, @path )
        relative_path = File.dirname( file )

        next [relative_path] if File.zero?( full_path )

        File.open( full_path ).collect do | line |
          line.chomp!
          next if line.empty?
          next line if relative_path == '.'
          File.join( relative_path, line )
        end.compact
      end.flatten.sort
    end

  end

end
