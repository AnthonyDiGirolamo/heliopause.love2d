source_files = Rake::FileList["*.lua", "shine/*.lua"]

LOVEFILE = "heliopause.love"

task default: [LOVEFILE, :launch]
# file LOVEFILE => source_files do |t|
task LOVEFILE do |t|
  rm_f LOVEFILE
  rm_f "~/storage/downloads/#{LOVEFILE}"
  sh "moonc *.moon"
  sh "zip -r #{LOVEFILE} *"
  sh "cp #{LOVEFILE} ~/storage/downloads/"
end

task :launch do
  sh "am start -d 'file:///sdcard/Download/#{LOVEFILE}' --user 0 -t 'application/*' -a android.intent.action.VIEW"
end
