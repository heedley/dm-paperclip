# TODO: bring in mimtype_fu tests

module Paperclip
  # The Upfile module is a convenience module for adding uploaded-file-type methods
  # to the +File+ class. Useful for testing.
  #   user.avatar = File.new("test/test_avatar.jpg")
  module Upfile

    EXTENSIONS = YAML.load_file(File.dirname(__FILE__) + '/mime/mime_types.yml').to_mash unless const_defined?('EXTENSIONS')

    # Infer the MIME-type of the file from its extension.
    # Below taken from mimetype-fu by Matt Aimonetti
    def content_type
      if (self.class == File || self.class == Tempfile)
        unless RUBY_PLATFORM.include? 'mswin32'
          mime = `file --mime -br #{self.path}`.strip
        else
          mime = EXTENSIONS[File.extname(self.path).gsub('.','').downcase.to_sym]
        end
      elsif (self.class == String)
        mime = EXTENSIONS[(self[self.rindex('.')+1, self.size]).downcase.to_sym]
      elsif (self.class == StringIO)
        temp = File.open(Dir.tmpdir + '/upload_file.' + Process.pid.to_s, "wb")
        temp << self.string
        temp.close
        mime = `file --mime -br #{temp.path}`
        mime = mime.gsub(/^.*: */,"")
        mime = mime.gsub(/;.*$/,"")
        mime = mime.gsub(/,.*$/,"")
        File.delete(temp.path)
      end

      if mime
        return mime
      else
        'unknown/unknown'
      end
    end

    # Returns the file's normal name.
    def original_filename
      File.basename(self.path)
    end

    # Returns the size of the file.
    def size
      File.size(self)
    end
  end

end

class File #:nodoc:
  include Paperclip::Upfile
end
