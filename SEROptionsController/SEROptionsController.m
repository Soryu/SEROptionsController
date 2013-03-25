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
{
  CGFloat _panOriginalY;
}

@property (nonatomic, copy) SEROptionsChangedBlock changedBlock;
@property (nonatomic, copy) SEROptionsAfterDismissalBlock afterDismissalBlock;

@end

static const NSTimeInterval kAnimationDuration = 0.25;

@implementation SEROptionsController

- (void)loadView
{
  self.capturingView = [UIView new];
  self.capturingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
  UITapGestureRecognizer *tapGestureRecognizer   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
  UIPanGestureRecognizer *swipeGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
  [self.capturingView addGestureRecognizer:tapGestureRecognizer];
  [self.capturingView addGestureRecognizer:swipeGestureRecognizer];
  
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

- (void)presentInView:(UIView *)view selectionChanged:(SEROptionsChangedBlock)changedBlock afterDismissal:(SEROptionsAfterDismissalBlock)afterDismissalBlock
{
  NSAssert([_values count] > 0, @"values not set?");
  
  self.changedBlock = changedBlock;
  self.afterDismissalBlock = afterDismissalBlock;

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
  [self dismissWithDuration:kAnimationDuration options:UIViewAnimationOptionCurveEaseIn];
}

- (void)dismissWithDuration:(NSTimeInterval)duration options:(NSUInteger)options
{
  [UIView animateWithDuration:duration
    delay:0.0
    options:options
    animations:^{
      self.tableView.transform = CGAffineTransformMakeTranslation(0.0, -self.tableView.frame.size.height);
      self.view.alpha = 0.0;
    }
    completion:^(BOOL finished) {
      [self.view removeFromSuperview];
      self.tableView.transform = CGAffineTransformIdentity;

      self.afterDismissalBlock();
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

- (void)handleTap:(UITapGestureRecognizer *)sender
{
  if (sender.state == UIGestureRecognizerStateRecognized)
  {
    [self dismiss];
  }
}

- (void)handleSwipe:(UIPanGestureRecognizer *)sender
{
  if (sender.state == UIGestureRecognizerStateBegan)
  {
    _panOriginalY = self.tableView.transform.ty;
  }
  else if (sender.state == UIGestureRecognizerStateChanged)
  {
    CGFloat possibleY = _panOriginalY + [sender translationInView:sender.view].y;
    
    // do not allow table to be dragged downwards
    if (possibleY < 0.0)
    {
      self.tableView.transform = CGAffineTransformMakeTranslation(0.0, possibleY);
      self.view.alpha = 1.0 - fmin(1.0, fmax(0.0, fabs(possibleY) / self.tableView.frame.size.height));
    }
  }
  else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
  {
    CGFloat yVelocity = [sender velocityInView:sender.view].y;
    if (yVelocity > 0.0)
    {
      // user dragged it open again
      [UIView animateWithDuration:kAnimationDuration
        delay:0.0
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
          self.tableView.transform = CGAffineTransformIdentity;
          self.view.alpha = 1.0;
        }
        completion:NULL
      ];
    }
    else
    {
      NSTimeInterval duration = CGRectGetMaxY(self.tableView.frame) / fabs(yVelocity);
      [self dismissWithDuration:fmin(fmax(0.05, duration), kAnimationDuration) options:UIViewAnimationCurveLinear];
    }
  }
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
