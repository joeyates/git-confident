require 'rubygems' if RUBY_VERSION < '1.9'
require 'rake'
require 'rake/gempackagetask'
require 'spec/rake/spectask'
require 'rake/rdoctask'
$:.unshift( File.dirname( __FILE__ ) + '/lib' )
require 'git/confident'

ADMIN_FILES          = FileList[ 'Rakefile', 'README.rdoc' ]
SOURCE_FILES         = FileList[ 'bin/*', 'lib/**/*.rb' ]
SPEC_FILES           = FileList[ 'spec/**/*' ]
RDOC_FILES           = FileList[ 'README.rdoc' ] + SOURCE_FILES
RDOC_OPTS            = [ '--quiet', '--main', 'README.rdoc', '--inline-source' ]

spec = Gem::Specification.new do |s|
  s.name             = 'git-confident'
  s.summary          = 'Automate computer configuration backup'
  s.description      = 'Provides git-confident'
  s.version          = Git::Confident::VERSION::STRING

  s.homepage         = 'http://github.com/joeyates/git-confident'
  s.author           = 'Joe Yates'
  s.email            = 'joe.g.yates@gmail.com'

  s.files            = ADMIN_FILES +
                       SOURCE_FILES
  s.executables      += [ 'git-confident' ]
  s.require_paths    = [ 'lib' ]
  s.add_dependency( 'rake', '>= 0.8.7' )
  s.add_dependency( 'git', '>= 1.2.5' )

  s.has_rdoc         = true
  s.rdoc_options     += RDOC_OPTS
  s.extra_rdoc_files = RDOC_FILES

  s.test_files       = SPEC_FILES
end

Rake::GemPackageTask.new( spec ) do |pkg|
end

Spec::Rake::SpecTask.new do |t|
  t.spec_files       = FileList[ 'spec/**/*_spec.rb' ]
  t.spec_opts        += [ '--color', '--format specdoc' ]
end

Spec::Rake::SpecTask.new( 'spec:rcov' ) do |t|
  t.spec_files       = FileList[ 'spec/**/*_spec.rb' ]
  t.rcov             = true
  t.rcov_opts        = [ '--exclude spec' ]
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir      = 'html'
  rdoc.options       += RDOC_OPTS
  rdoc.title         = 'Automate computer configuration backup'
  rdoc.rdoc_files.add RDOC_FILES
end
