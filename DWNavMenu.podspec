Pod::Spec.new do |s|

  s.name         = "DWNavMenu"
  s.version      = "1.0.4"
  s.summary      = "A highly customizable UIActionSheet style menu with simple navigation and block handling"

  s.description  = <<-DESC
                   This class is a simple navigation menu in the style of a UIActionSheet. This class makes it easy to create seamless menu funnels using block handling and simple navigation. Includes all the features of a UIActionSheet, and all navigation handling is done internally. Also supports landscape and portrait orientation changes. All button sizes, fonts, colors, spacing, and et cetera is all customizable and can be found in the DWNavMenu header file.
                   DESC

  s.homepage     = "https://github.com/dwalker39/DWNavMenu"
  s.license      = "Apache License"
  s.author       = { "Derrick Walker" => "derrick@mtsr-app.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/dwalker39/DWNavMenu.git", :tag => "v1.0.4" }
  s.source_files  = "DWNavMenu/*.{h,m}"
  s.public_header_files = "DWNavMenu/*.h"
  s.requires_arc = true

end
