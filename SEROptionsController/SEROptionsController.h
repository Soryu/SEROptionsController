//
//  SEROptionsController.h
//
//  Created by Stanley Rost on 22.03.13.
// (c) 2013 Stanley Rost
//

typedef NSString *(^SEROptionsStringTransformationBlock)(id);
typedef UIImage *(^SEROptionsImageTransformationBlock)(id);
typedef void (^SEROptionsChangedBlock)(id value, BOOL on);
typedef void (^SEROptionsCellConfigurationBlock)(UITableViewCell *cell, NSIndexPath *indexPath);

@interface SEROptionsController : UIViewController

/**
 * Block that transforms the values into NSStrings to be shown as title in the table rows
 */
@property (nonatomic, copy) SEROptionsStringTransformationBlock stringTransformationBlock;

/**
 * optional block that transforms values into images
 */
@property (nonatomic, copy) SEROptionsImageTransformationBlock imageTransformationBlock;

/**
 * optional block called for each table cell to customize it
 */
@property (nonatomic, copy) SEROptionsCellConfigurationBlock cellConfigurationBlock;

/**
 * exposed UI components to allow customization
 */
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *capturingView;

/**
 * all values and preselected values
 */
@property (nonatomic, strong) NSArray *values;
@property (nonatomic, strong) NSArray *selectedValues;

/**
 * Methods to show and hide (animated) the component
 */
- (void)presentInView:(UIView *)view selectionChanged:(SEROptionsChangedBlock)changedBlock;
- (void)dismiss;


@end
