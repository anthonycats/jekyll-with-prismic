module Jekyll
  # Add helper methods for dealing with Prismic to the Site class
  class Site
    def prismic
      return nil unless has_prismic?

      @prismic_api ||= ::Prismic.api(@config['prismic']['endpoint'], {
        :access_token => @config['prismic']['access_token'],
        :cache => ::Prismic::BasicNullCache.new
      })
    end

    def prismic_collections
      return Array.new unless has_prismic_collections?
      @prismic_collections ||= Hash[@config['prismic']['collections'].map { |name, config| [name, Prismic::PrismicCollection.new(self, name, config)] }]
    end

    def has_prismic?
      @config['prismic'] != nil
    end

    def has_prismic_collections?
      has_prismic? and @config['prismic']['collections'] != nil
    end

    def prismic_ref
      @prismic_ref ||= prismic.refs[@config['prismic']['ref']] || prismic.master_ref
    end

    def prismic_document(id)
      begin
        response = prismic.form('everything')
          .query(::Prismic::Predicates::at('document.type', id))
          .lang(self.config['lang'])
          .submit(prismic_ref)

        response.results.first
      rescue ::Prismic::SearchForm::FormSearchException
        nil
      end
    end

    def prismic_document_by_id(id)
      begin
        response = prismic.form('everything')
          .query(::Prismic::Predicates::at('document.id', id))
          .lang(self.config['lang'])
          .submit(prismic_ref)

        response.results.first
      rescue ::Prismic::SearchForm::FormSearchException
        nil
      end
    end

    def prismic_link_resolver
      @prismic_link_resolver ||= ::Prismic.link_resolver prismic_ref do |link|
        if @config['prismic'] != nil and @config['prismic']['links'] != nil
          url = nil

          @config['prismic']['links'].each do |type, link_config|
            if (link.is_a? ::Prismic::Fragments::DocumentLink or link.is_a? ::Prismic::Document) and type == link.type
              url = Jekyll::URL.new(:template => link_config['permalink'], :placeholders => {
                :id => link.id,
                :uid => link.uid,
                :slug => link.slug,
                :type => link.type
              })
            end
          end

          url.to_s
        end
      end
    end

    def prismic_collection(collection_name)
      prismic_collections[collection_name]
    end


  alias :process_org :process
    
  #======================================
  # process
  #
  # Reads Jekyll and plugin configuration parameters set on _config.yml, sets
  # main parameters and processes the website for each language.
  #======================================
  def process
    # Check if plugin settings are set, if not, set a default or quit.
    #-------------------------------------------------------------------------
    
    self.config['exclude_from_localizations'] ||= []
    
    if ( !self.config['languages']         or
          self.config['languages'].empty?  or
         !self.config['languages'].all?
       )
        puts 'You must provide at least one language using the "languages" setting on your _config.yml.'
        
        exit
    end
     
    # Variables
    #-------------------------------------------------------------------------
    
    # Original Jekyll configurations
    baseurl_org                 = self.config[ 'baseurl' ] # Baseurl set on _config.yml
    dest_org                    = self.dest                # Destination folder where the website is generated
    exclude_org                 = self.exclude
    
    # Site building only variables
    languages                   = self.config['languages'] # List of languages set on _config.yml

    # Site wide plugin configurations
    self.config['default_lang'] = languages.first[0]          # Default language (first language of array set on _config.yml)
    self.config[        'lang'] = languages.first[0]          # Current language being processed
    self.config['baseurl_root'] = baseurl_org              # Baseurl of website root (without the appended language code)
    
    # Build the website for root content

    @exclude += ['*.html'] # Exclude all html files
    process_org
    
    # Build the website for the other languages
    #-------------------------------------------------------------------------
    
    # Remove .htaccess file from included files, so it wont show up on translations folders.
    self.include -= [".htaccess"]
    
    languages.each do |lang, config|
      
      # Language specific config/variables
      @dest                  = dest_org    + "/" + config['path']
      self.config['baseurl'] = baseurl_org + "/" + config['path']
      self.config['lang']    =                     lang
      self.config['langShort'] =                   config['path']
      
      puts "Building site for language: \"#{self.config['lang']}\" to: #{self.dest}"

      exclude_from_localizations = self.config['exclude_from_localizations']
      @exclude                   = exclude_org + exclude_from_localizations
      
      process_org
      @exclude = exclude_org
    end
    
    # Revert to initial Jekyll configurations (necessary for regeneration)
    self.config[ 'baseurl' ] = baseurl_org  # Baseurl set on _config.yml
    @dest                    = dest_org     # Destination folder where the website is generated
    puts 'Build complete'
  end

  end

end
