//
//  SEROptionsController.m
//
//  Created by Stanley Rost on 22.03.13.
// (c) 2013 Stanley Rost
//

#import "SEROptionsController.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

@interface SEROptionsController () <UITableViewDataSource>

@property (nonatomic, copy) SEROptionsChangedBlock changedBlock;

@end

static const NSTimeInterval kAnimationDuration = 0.25;

@implementation SEROptionsController

- (void)loadView
{
  self.capturingView = [UIView new];
  self.capturingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
  
  self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  self.tableView.allowsSelection = NO;
  self.tableView.dataSource = self;
  
  self.view = [UIView new];
  [self.view addSubview:self.capturingView];
  [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  self.capturingView.frame = self.view.bounds;
  
  if (self.tableView.frame.size.height == 0.0)
    self.tableView.frame = self.view.bounds;
}

- (void)setValues:(NSArray *)values
{
  _values = values;
  
  [self.tableView reloadData];
}

- (void)setSelectedValues:(NSArray *)values
{
  _selectedValues = values;

  [self.tableView reloadData];
}

- (void)presentInView:(UIView *)view selectionChanged:(SEROptionsChangedBlock)changedBlock
{
  NSAssert([_values count] > 0, @"values not set?");
  
  self.changedBlock = changedBlock;

  self.view.frame = view.bounds;
  self.view.alpha = 0.0;
  [view addSubview:self.view];
  
  self.tableView.transform = CGAffineTransformMakeTranslation(0.0, -self.tableView.frame.size.height);
  
  [UIView animateWithDuration:kAnimationDuration animations:^{
    self.view.alpha = 1.0;
    self.tableView.transform = CGAffineTransformIdentity;
  }];
}

- (void)dismiss
{
  [UIView animateWithDuration:kAnimationDuration
    animations:^{
      self.tableView.transform = CGAffineTransformMakeTranslation(0.0, -self.tableView.frame.size.height);
      self.view.alpha = 0.0;
    }
    completion:^(BOOL finished) {
      [self.view removeFromSuperview];
      self.tableView.transform = CGAffineTransformIdentity;
    }
  ];
}

#pragma mark Actions

- (void)switchChanged:(id)sender
{
  NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(sender, @"indexPath");
  id value = _values[indexPath.row];
  
  BOOL isOn = NO;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wint-conversion"
  if ([sender respondsToSelector:@selector(isOn)])
    isOn = [sender performSelector:@selector(isOn)]; // funnily this works. Using -boolValue will actually make it crash.
#pragma clang diagnostic pop
  
  NSMutableArray *mutableSelectedValues = [self.selectedValues mutableCopy];
  if (isOn && ![mutableSelectedValues containsObject:value])
  {
    [mutableSelectedValues addObject:value];
  }
  else if (!isOn)
  {
    [mutableSelectedValues removeObject:value];
  }
  
  _selectedValues = mutableSelectedValues; // do not call accessor here!
  
  if (self.changedBlock != NULL)
    self.changedBlock(value, isOn);
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_values count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  id value = [self.values objectAtIndex:indexPath.row];
  BOOL isOn = [self.selectedValues containsObject:value];
  
  static NSString * const identifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  
  if (!cell)
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  
  NSString *string = @"?";
  UIImage *image   = nil;

  if (self.stringTransformationBlock != NULL)
    string = self.stringTransformationBlock(value);

  if (self.imageTransformationBlock != NULL)
    image = self.imageTransformationBlock(value);
  
  cell.textLabel.text  = string;
  cell.imageView.image = image;
  
  if (self.cellConfigurationBlock)
    self.cellConfigurationBlock(cell, indexPath);
  
  if (!cell.accessoryView)
    cell.accessoryView = [UISwitch new];
  
  id control = cell.accessoryView;
  if ([control respondsToSelector:@selector(setOn:)])
    [control setOn:isOn];

  objc_setAssociatedObject(control, @"indexPath", indexPath, OBJC_ASSOCIATION_RETAIN);
  [control addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
  
  return cell;
}

@end
