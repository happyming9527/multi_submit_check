# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'multi_submit_check/version'

Gem::Specification.new do |spec|
  spec.name          = "multi_submit_check"
  spec.version       = MultiSubmitCheck::VERSION
  spec.authors       = ["happyMing"]
  spec.email         = ["339755551@qq.com"]
  spec.summary       = %q{基于rails4，在rails中添加config.multi_submit_check = true可以开启所有form_tag生成的表单，自动创建token。}
  spec.description   = %q{创建表单时，会创建和token配对的session，会进行表单重复提交的验证。}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
