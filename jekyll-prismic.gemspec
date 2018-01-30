$:.unshift(File.expand_path("../lib", __FILE__))
require "jekyll/prismic/version"

Gem::Specification.new do |spec|
  spec.version = Jekyll::Prismic::VERSION
  spec.homepage = "https://github.com/MediaComem/jekyll-prismic"
  spec.authors = ["Media Engineering Institute"]
  spec.email = ["mei@heig-vd.ch"]
  spec.files = %W(README.md LICENSE) + Dir["lib/**/*"]
  spec.summary = "Prismic.io integration for Jekyll"
  spec.name = "jekyll-prismic2"
  spec.license = "MIT"
  spec.has_rdoc = false
  spec.require_paths = ["lib"]
  spec.description =   spec.description   = <<-DESC
    A Jekyll plugin for retrieving content from the Prismic.io API
  DESC

  spec.add_runtime_dependency("prismic.io", "~> 1.6.1")
  spec.add_runtime_dependency("jekyll", "~> 3.7.2")
end
