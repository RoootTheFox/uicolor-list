#import "UICDBGRootViewController.h"
#import <objc/runtime.h>

@implementation UIColor (compare)
- (BOOL) isEqualToColor:(UIColor *) otherColor {
	return CGColorEqualToColor(self.CGColor, otherColor.CGColor);
}
@end

@interface UICDBGRootViewController ()
@property (nonatomic, strong) NSMutableArray * objects;
@end

@implementation UICDBGRootViewController

- (void)loadView {
	[super loadView];

	_objects = [NSMutableArray array];

	unsigned int count;
	Method *methods = class_copyMethodList(object_getClass([UIColor class]), &count);

	for (int i = 0; i < count; i++) {
		Method method = methods[i];
		const char* method_type = method_getTypeEncoding(method);

		// this filters for the methods we want
		if (strcmp(method_type, "@16@0:8") == 0) {
			NSLog(@"meow -> found method %s, type %s", sel_getName(method_getName(method)), method_type);

			[_objects addObject: [NSString stringWithUTF8String:sel_getName(method_getName(method))]];
		}
	}

	self.title = @"UIColor color list";
	//self.navigationItem.leftBarButtonItem = self.editButtonItem;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(bgToggleButtonTapped:)];

	self.view.backgroundColor = [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 1.0];
}

- (void)bgToggleButtonTapped:(id)sender {
	if ([self.tableView.backgroundColor isEqualToColor: [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 1.0]]) {
		self.tableView.backgroundColor = [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 1.0];
	} else {
		self.tableView.backgroundColor = [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 1.0];
	}
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		NSString *colorName = _objects[indexPath.row];
		UIColor *color = [UIColor performSelector:NSSelectorFromString(colorName)];

		cell.textLabel.text = colorName;
		cell.textLabel.textColor = color;
		cell.backgroundColor = [UIColor clearColor];
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	//[_objects removeObjectAtIndex:indexPath.row];
	//[tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
