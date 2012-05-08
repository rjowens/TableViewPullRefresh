#  RootViewController
# 
#  RubyMotion implementation of https://github.com/enormego/EGOTableViewPullRefresh
#
#  Created By Richard Owens, 2012/05/04
#  Copyright 2012 Richard Owens.  All rights reserved. 
# 
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
class RootViewController < UITableViewController
  def loadView
    self.tableView = UITableView.new
  end

  def viewDidAppear(animated)
    @refreshHeaderView ||= begin
      rhv = RefreshTableHeaderView.alloc.initWithFrame(CGRectMake(0, 0 - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
      rhv.delegate = self
      rhv.refreshLastUpdatedDate    
      tableView.addSubview(rhv)
      rhv
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
    cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:(cellIdentifier)) 
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