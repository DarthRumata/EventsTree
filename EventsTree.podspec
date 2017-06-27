Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "EventsTree"
  s.module_name  = "EventsTree"
  s.version      = "0.1.3"
  s.summary      = "Library for sending and handling events"
  s.description  = <<-DESC
    This library is inteded to get rid of spagetti code which comes
    with communication of different parts of app
                   DESC
  s.homepage     = "https://github.com/DarthRumata/EventsTree"
  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = { :type => "MIT", :file => "LICENSE" }
  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "Stas Kirichok" => "kirichok.stas@gmail.com" }
  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
   s.ios.deployment_target = "9.0"
   s.osx.deployment_target = "10.10"
   s.watchos.deployment_target = "2.0"
   s.tvos.deployment_target = "9.0"
  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/DarthRumata/EventsTree.git", :tag => s.version }
  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "Sources"
  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.framework  = "Foundation"

end
