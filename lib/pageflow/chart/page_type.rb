module Pageflow
  module Chart
    class PageType < Pageflow::PageType
      name 'chart'

      def view_helpers
        [ScrapedSitesHelper]
      end

      def json_seed_template
        'pageflow/chart/page_type.json.jbuilder'
      end

      def file_types
        [Chart.scraped_site_file_type]
      end
    end

    def self.scraped_site_file_type
      FileType.new(model: ScrapedSite,
                   custom_attributes: %i[url use_custom_theme],
                   editor_partial: 'pageflow/chart/editor/scraped_sites/scraped_site')
    end
  end
end
