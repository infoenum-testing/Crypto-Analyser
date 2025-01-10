platform :ios, '13.0'

plugin 'cocoapods-keys', {
  :project => "Crypto Analyser",
  :keys => [
    "ChatGPtApiKey"
  ]}

def shared_pods
  use_frameworks!
   pod 'SwiftyJSON', '~> 5.0'
end

target 'Crypto Analyser Dev' do
  shared_pods
end

target 'Crypto Analyser Pro' do
  shared_pods
end


deployment_target = '13.0'

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
              config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = deployment_target
              if target.respond_to?(:product_type) and target.product_type ==
                "com.apple.product-type.bundle"
                target.build_configurations.each do |config|
                  config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
                end
              end
            end
        end
        project.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = deployment_target
        end
    end
end
