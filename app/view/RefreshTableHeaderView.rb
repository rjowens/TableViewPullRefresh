class RefreshTableHeaderView < UIView

  attr_accessor :delegate
    
  def initWithFrame(frame)
    if super
      self.autoresizingMask = UIViewAutoresizingFlexibleWidth      
      self.backgroundColor = UIColor.colorWithRed(226.0/255, green:231.0/255, blue: 237.0/255, alpha:1)
      
      @lastUpdatedLabel = UILabel.alloc.initWithFrame(CGRectMake(0, frame.size.height - 30, frame.size.width, 20))
      @lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth
      @lastUpdatedLabel.font = UIFont.systemFontOfSize(12)
      @lastUpdatedLabel.textColor = UIColor.colorWithRed(87.0/255, green:108.0/255, blue:237.0/137, alpha:1.0)
      @lastUpdatedLabel.shadowColor = UIColor.colorWithWhite(0.9, alpha:1.0)
      @lastUpdatedLabel.shadowOffset = CGSizeMake(0,1)
      @lastUpdatedLabel.backgroundColor = UIColor.clearColor
      @lastUpdatedLabel.textAlignment = UITextAlignmentCenter      
      self.addSubview(@lastUpdatedLabel)

      @statusLabel = UILabel.alloc.initWithFrame(CGRectMake(0, frame.size.height-48, frame.size.width, 20))
      @statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth
      @statusLabel.font = UIFont.boldSystemFontOfSize(13)
      @statusLabel.textColor = UIColor.colorWithRed(87.0/255, green:108.0/255, blue:237.0/137, alpha:1.0)
      @statusLabel.shadowColor = UIColor.colorWithWhite(0.9, alpha:1.0)
      @statusLabel.shadowOffset = CGSizeMake(0,1)
      @statusLabel.backgroundColor = UIColor.clearColor
      @statusLabel.textAlignment = UITextAlignmentCenter
      self.addSubview(@statusLabel)

      @arrowImage = CALayer.layer
      @arrowImage.frame = CGRectMake(25, frame.size.height-65, 30, 55)
      @arrowImage.contentsGravity = KCAGravityResizeAspect
      @arrowImage.contents = UIImage.imageNamed("blueArrow.png").CGImage
      @arrowImage.contentsScale = UIScreen.mainScreen.scale
      self.layer.addSublayer(@arrowImage)

      @activityView = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray)
      @activityView.frame = CGRectMake(25, frame.size.height - 38, 20, 20)
      self.addSubview(@activityView)
      
      setState(:pullRefreshNormal)
    end
    self
  end

  def refreshLastUpdatedDate
    if @delegate.respond_to? "refreshTableHeaderDataSourceLastUpdated"
      date = @delegate.refreshTableHeaderDataSourceLastUpdated(self)
      @lastUpdatedLabel.text = date.to_s
    else
      @lastUpdatedLabel.text = nil
    end
  end

  def setState(state) 
    if state == :pullRefreshPulling
      @statusLabel.text = "Release to refresh..."
      CATransaction.begin
      CATransaction.setAnimationDuration(0.5)
      @arrowImage.transform = CATransform3DMakeRotation((Math::PI / 180) * 180, 0, 0, 1)
      CATransaction.commit
    elsif state == :pullRefreshNormal
      if @state == :pullRefreshPulling
        CATransaction.begin
        CATransaction.setAnimationDuration(0.5)
        @arrowImage.transform = CATransform3DIdentity 
        CATransaction.commit
      end 
      @statusLabel.text = "Pull down to refresh..."
      @activityView.stopAnimating
      CATransaction.begin
      CATransaction.setValue(true, forKey:(KCATransactionDisableActions))
      @arrowImage.hidden = false
      @arrowImage.transform = CATransform3DIdentity
      CATransaction.commit

    elsif state == :pullRefreshLoading
      @statusLabel.text = "Loading..."
      @activityView.startAnimating
      CATransaction.begin
      CATransaction.setValue(true, forKey:KCATransactionDisableActions)
      @arrowImage.hidden = true
      CATransaction.commit    
    end
    @state = state
  end

  def refreshScrollViewDidScroll(scrollView)
    if @state == :pullRefreshLoading
      offset = scrollView.contentOffset.y * -1 > 0 ? scrollView.contentOffset.y * -1 : 0
      offset = offset < 60 ? offset : 60
      scrollView.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0)
    elsif scrollView.isDragging
      loading = false
      loading = @delegate.refreshTableHeaderDataSourceIsLoading(self) if @delegate.respond_to? "refreshTableHeaderDataSourceIsLoading"
      if @state == :pullRefreshPulling && scrollView.contentOffset.y > -65.0 && scrollView.contentOffset.y < 0 && !loading
        setState(:pullRefreshNormal)
      elsif @state == :pullRefreshNormal && scrollView.contentOffset.y < -65 && !loading
        setState(:pullRefreshPulling)
      end
      scrollView.contentInset = UIEdgeInsetsZero if scrollView.contentInset.top != 0
    end
  end

  def refreshScrollViewDidEndDragging(scrollView)
    loading = false
    loading = @delegate.refreshTableHeaderDataSourceIsLoading(scrollView) if @delegate.respond_to?"refreshTableHeaderDataSourceIsLoading"
    if (scrollView.contentOffset.y < -65 && !loading) 
      @delegate.refreshTableHeaderDidTriggerRefresh(self) if @delegate.respond_to?"refreshTableHeaderDidTriggerRefresh"
      setState(:pullRefreshLoading)
      UIView.animateWithDuration(0.2, 
        animations: -> do
          scrollView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0)
        end,
        completion: ->(finished) do
        end)
    end
  end

  def refreshScrollViewDataSourceDidFinishLoading(scrollView)
    UIView.animateWithDuration(0.3,
      animations: -> do
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
      end,
      completion: ->(finished) do
      end
    )
    setState(:pullRefreshNormal)
  end

end


