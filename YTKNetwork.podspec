Pod::Spec.new do |s|

  s.name         = "YTKNetwork"
  s.version      = "1.1.2"
  s.summary      = "修改了YTKNetwork自定义请求返回数据的反序列化方式"
  s.homepage     = "https://github.com/yuantiku/YTKNetwork"
  s.license      = "MIT"
  s.author             = {
                          "tangqiao" => "tangqiao@fenbi.com",
                          "lancy" => "lancy@fenbi.com",
                          "maojj" => "maojj@fenbi.com"
 }
  s.source        = { :git => "https://github.com/yuantiku/YTKNetwork.git", :tag => s.version.to_s }
  s.source_files  = "YTKNetwork/*.{h,m}"
  s.platform      = :ios, '6.0'
  s.requires_arc  = true
  s.dependency "AFNetworking", "~> 2.0"
  s.dependency "AFDownloadRequestOperation", "~> 2.0"
  s.ios.deployment_target = '7.0'
  s.watchos.deployment_target = '2.0'
end
