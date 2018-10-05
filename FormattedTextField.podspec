Pod::Spec.new do |spec|
  spec.name               = 'FormattedTextField'
  spec.version            = '0.4'
  spec.summary            = 'iOS formatted text field which supports symbols with variable-width encoding'
  spec.homepage           = 'https://github.com/seaburg/FormattedTextField'
  spec.license            =  { :type => "MIT", :file => "LICENSE" }
  spec.author             =  { "Evgeniy Yurtaev" => "evgeniyyurt@gmail.com" }
  spec.source             =  { :git => 'https://github.com/seaburg/FormattedTextField.git', :tag => '0.4' }
  spec.source_files       = 'FormattedTextField/*.swift'
  spec.platform           = :ios, "8.0"
  spec.requires_arc       = true
end
