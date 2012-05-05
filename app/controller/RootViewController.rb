class RootViewController < UITableViewController
  def loadView
    self.tableView = UITableView.new
  end

  def viewDidAppear(animated)
    if !@refreshHeaderView
      @refreshHeaderView = RefreshTableHeaderView.alloc.initWithFrame(CGRectMake(0, 0 - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
      @refreshHeaderView.delegate = self
      @refreshHeaderView.refreshLastUpdatedDate    
      tableView.addSubview(@refreshHeaderView)
    end 
  end
    
  def numberOfSectionsInTableView(tableView)
    10
  end
  
  def tableView(tableView, numberOfRowsInSection:section) 
    4
  end
  
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cellIdentifier = "Cell"
    cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
    unless cell
       cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:(cellIdentifier)) 
    end
    return cell    
  end
  
  def tableView(tableView, titleForHeaderInSection:section) 
    "Section: #{section}"
  end
  
  def reloadTableViewDataSource
    @reloading = true
  end
  
  def doneReloadingTableViewData
    @reloading = false
    @refreshHeaderView.refreshScrollViewDataSourceDidFinishLoading(self.tableView)
  end
  
  def scrollViewDidScroll(scrollView)
    @refreshHeaderView.refreshScrollViewDidScroll(scrollView)
  end
  
  def scrollViewDidEndDragging(scrollView, willDecelerate:decelerate)
    @refreshHeaderView.refreshScrollViewDidEndDragging(scrollView)
  end
  
  def refreshTableHeaderDidTriggerRefresh(view)
    self.reloadTableViewDataSource
    self.performSelector('doneReloadingTableViewData', withObject:nil, afterDelay:3)
  end
    
  def refreshTableHeaderDataSourceIsLoading(view)
    @reloading
  end
  
  def refreshTableHeaderDataSourceLastUpdated(view)
    NSDate.date
  end
  
end