Pod::Spec.new do |s|
  s.name         = "PagingMenu"
  s.version      = "1.0.0"
  s.summary      = "paging menu"
  s.homepage     = "https://github.com/iLiuChang/PagingMenu"
  s.license      = "MIT"
  s.authors      = { "iLiuChang" => "iliuchang@foxmail.com" }
  s.platform     = :ios, "11.0"
  s.source       = { :git => "https://github.com/iLiuChang/PagingMenu.git", :tag => s.version }
  s.requires_arc = true
  s.swift_version = "5.0"
  s.source_files = "Source/*.{swift}"
end
