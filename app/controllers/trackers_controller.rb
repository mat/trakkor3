
class TrackersController < ApplicationController

  def index
    trackers = Tracker.live_examples

    last_modified = trackers.map{ |t| t.last_modified }.max
    fresh_when(:last_modified => last_modified, :public => true)

    @trackers = trackers
  end

  def show
    @tracker = Tracker.find_by_code(params[:id])

    unless @tracker
      render :text => 'No tracker found for this id.', :status => 404
      return
    end

    if stale?(:last_modified => @tracker.last_modified, :public => true)
      @changes = @tracker.pieces

      respond_to do |format|
        format.html
        format.atom
      end
    end
  end

  def new
    @tracker = Tracker.new(params[:tracker])

    if @tracker.uri && @tracker.xpath
      @piece = @tracker.fetch_piece

      if @tracker.name.blank?
        html_title = @tracker.html_title.to_s
        html_title = "#{html_title[0..50]}..." if html_title.length > 50
        @tracker.name = "Tracking '#{html_title}'"
      end
    end
  end

  def find_xpath
    @hits = flash[:error] = nil
    @uri  = params[:uri]
    @q    = params[:q]

    if @uri.blank? || @q.blank?
      flash[:error] = "Please provide an URI and a search term."
      return
    end

    doc, err = Tracker.fetch_doc_from(@uri)
    if doc
      @hits =  Tracker.find_nodes_by_text(doc, @q)
    else
      flash[:error] = err
    end
  end

  def test_xpath
    @uri = params[:uri]
    @xpath = params[:xpath]

    if @uri.blank? || @xpath.blank?
      flash[:error] = "Please provide an URI and an XPath."
      return
    end

    doc, err = Tracker.fetch_doc_from(@uri)
    if doc
      @elem, @parents = Piece.extract_with_parents(doc, @xpath)
    else
      flash[:error] = err
    end
  end

  def stats
    authenticate
    @trackers = Tracker.all
  end

  def update
    TrackerUpdater.new(Rails.logger).update_trackers
    render text: "Ok"
  end

  def create
    @tracker = Tracker.new(params[:tracker])

    if @tracker.save
      flash[:notice] = 'Tracker was successfully created.'

      redirect_path = tracker_path(id: @tracker.code)
      redirect_to redirect_path
    else
      render :action => "new"
    end
  end

  def destroy
    if params[:cancel]
      redirect_to(stats_path) and return
    end

    tracker = Tracker.find_by_code(params[:id])
    tracker.destroy
    respond_to do |format|
      format.html { redirect_to stats_path }
      format.js { render :nothing => true }
    end
  end

  private

  def authenticate
    authenticate_or_request_with_http_basic("Trakkor stats") do |username, password|
      username == "admin" && password == APP_CONFIG['password']
    end
  end
end
