module Pageflow
  module Chart
    class ScrapedSite < ActiveRecord::Base
      has_attached_file :javascript_file, Chart.config.paperclip_options(extension: 'js')
      has_attached_file :stylesheet_file, Chart.config.paperclip_options(extension: 'css')
      has_attached_file :html_file, Chart.config.paperclip_options(extension: 'html')
      has_attached_file :csv_file, Chart.config.paperclip_options(basename: 'data', extension: 'csv')

      state_machine initial: 'unprocessed' do
        extend StateMachineJob::Macro

        state 'unprocessed'
        state 'processing'
        state 'processing_failed'
        state 'processed'

        event :process do
          transition 'unprocessed' => 'processing'
        end

        event :reprocess do
          transition 'processed' => 'processing'
          transition 'processing_failed' => 'processing'
        end

        job ScrapeSiteJob do
          on_enter 'processing'
          result ok: 'processed'
          result error: 'processing_failed'
        end
      end

      def csv_url
        URI.join(url, 'data.csv').to_s
      end

      def as_json(*)
        super.merge(html_file_url: html_file_url)
      end

      def html_file_url
        return unless html_file.try(:path)
        if Chart.config.scraped_sites_root_url.present?
          File.join(Chart.config.scraped_sites_root_url, html_file.path)
        else
          html_file.url
        end
      end
    end
  end
end
