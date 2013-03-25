//
//  SEROptionsControllerDemoViewController.m
//  SEROptionsControllerDemo
//
//  Created by Stanley Rost on 23.03.13.
//  Copyright (c) 2013 Stanley Rost. All rights reserved.
//

#import "SEROptionsControllerDemoViewController.h"
#import "SEROptionsController.h"
#import "SERDomainObject.h"
#import <QuartzCore/QuartzCore.h>

@interface SEROptionsControllerDemoViewController ()

@property (nonatomic, strong) SEROptionsController *optionsController;
@property (nonatomic, strong) UILabel *resultLabel;

@end

@implementation SEROptionsControllerDemoViewController

- (void)loadView
{
  UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"foo.png"]];
  imageView.center = CGPointMake(160.0, 100.0);
  
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 150.0, 320.0, 150.0)];
  label.text = @"Use the button in the navigation bar to bring up and dismiss the options.\n\nThis demo project includes icons from glyphish http://www.glyphish.com.";
  label.textAlignment = UITextAlignmentCenter;
  label.numberOfLines = 0;
  label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.];
  
  self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 350.0, 320.0, 25.0)];
  self.resultLabel.textColor = [UIColor redColor];
  self.resultLabel.textAlignment = UITextAlignmentCenter;
  self.resultLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.];

  
  self.view = [UIView new];
  [self.view addSubview:imageView];
  [self.view addSubview:label];
  [self.view addSubview:self.resultLabel];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = @"SEROptionsController";

  UIButton *optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [optionsButton setImage:[UIImage imageNamed:@"options-button.png"] forState:UIControlStateNormal];
  [optionsButton addTarget:self action:@selector(showOptions:) forControlEvents:UIControlEventTouchUpInside];
  [optionsButton sizeToFit];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:optionsButton];
}

- (void)showOptions:(id)sender
{
  if (self.optionsController)
  {
    [self.optionsController dismiss];
    return;
  }
  
  self.optionsController = [SEROptionsController new];
  
  self.optionsController.values = @[
    [SERDomainObject objectOfType:kTypeFoo],
    [SERDomainObject objectOfType:kTypeBar],
    [SERDomainObject objectOfType:kTypeBaz],
  ];
  
  self.optionsController.selectedValues = @[
    [SERDomainObject objectOfType:kTypeFoo],
    [SERDomainObject objectOfType:kTypeBaz],
  ];
  
  // block to transform input values into strings to be displayed in the table cells
  self.optionsController.stringTransformationBlock = ^(SERDomainObject *object) {
    return [SERDomainObject stringForType:object.type];
  };
  
  // optional block to transform input values into image icons to be displayed in the table cells
  self.optionsController.imageTransformationBlock = ^(SERDomainObject *object) {
    return [SERDomainObject imageForType:object.type];
  };
  
  // optional block to configure table cells
  self.optionsController.cellConfigurationBlock = ^(UITableViewCell *cell, NSIndexPath *indexPath)
  {
    cell.textLabel.font            = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    UIImage *image =
      [[UIImage imageNamed:@"options-cell-background.png"]
        resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 0.0, 1.0, 0.0)];
    cell.backgroundView = [[UIImageView alloc] initWithImage:image];

    // setting cell.accessoryView with a custom switch (must respond to `-on` and `-setOn:`)
    // cell.accessoryView = [[TTSwitch alloc] initWithFrame:CGRectMake(0.0, 0.0, 76.0, 27.0)];
  };
  
  // optional: customize table view appearance a bit
  [self.optionsController view]; // make sure view is loaded
  self.optionsController.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  self.optionsController.tableView.backgroundColor = [UIColor clearColor];
  self.optionsController.tableView.scrollEnabled   = NO;
  self.optionsController.tableView.layer.cornerRadius = 5.0;
  self.optionsController.tableView.frame = CGRectMake(0.0, -5.0, self.view.bounds.size.width, 44.0 * [self.optionsController.values count] + 5.0);
  self.optionsController.tableView.contentInset = UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0);
  
  // present the thing
  [self.optionsController presentInView:self.view
    selectionChanged:^(SERDomainObject *object, BOOL on) {
    // ... do something as a result of the value being changed
      self.resultLabel.text = [NSString stringWithFormat:@"%@ toggled %@", object, on ? @"on" : @"off"];
    }
    afterDismissal:^{
      self.optionsController = nil;
    }
  ];
}

@end
