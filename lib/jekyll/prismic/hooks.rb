module Jekyll
  module Prismic
    # Add Prismic Liquid variables to all templates
    Jekyll::Hooks.register :site, :pre_render do |site, payload|
      payload['site']['prismicData'] = PrismicDrop.new(site)
    end

    Jekyll::Hooks.register :site, :post_render do |site, payload|
    
	    # Removes all static files that should not be copied to translated sites.
	    #===========================================================================
	    default_lang  = payload["site"]["default_lang"]
	    current_lang  = payload["site"][        "lang"]
	    
	    static_files  = payload["site"]["static_files"]
	    exclude_paths = payload["site"]["exclude_from_localizations"]

			if default_lang != current_lang
				static_files.delete_if do |static_file|
	        
	        # Remove "/" from beginning of static file relative path
	        static_file_r_path    = static_file.instance_variable_get(:@relative_path).dup
	        static_file_r_path[0] = ''
	        
	        exclude_paths.any? do |exclude_path|
	          Pathname.new(static_file_r_path).descend do |static_file_path|
	            break(true) if (Pathname.new(exclude_path) <=> static_file_path) == 0
	          end
	        end
	      end
	    end
    end

    Jekyll::Hooks.register :site, :after_reset do |site|
      #site.prismic.cache.invalidate_all!
    end
  end
end
