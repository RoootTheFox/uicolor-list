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

	NSArray *blacklist = @[
		@"writableTypeIdentifiersForItemProvider",
		@"classFallbacksForKeyedArchiver",
		@"readableTypeIdentifiersForItemProvider",
		@"_apiColorNames",
		@"_systemColorSelectorTable",
	];


	_objects = [NSMutableArray array];

	unsigned int count;
	Method *methods = class_copyMethodList(object_getClass([UIColor class]), &count);

	for (int i = 0; i < count; i++) {
		Method method = methods[i];
		const char* method_type = method_getTypeEncoding(method);


		// this filters for the methods we want
		if (strcmp(method_type, "@16@0:8") == 0) {
			NSLog(@"meow -> found method %s, type %s", sel_getName(method_getName(method)), method_type);

			NSString* method_str = [NSString stringWithUTF8String:sel_getName(method_getName(method))];
			if ([blacklist containsObject:method_str]) {
				NSLog(@"meow -> skipped method %s, type %s", sel_getName(method_getName(method)), method_type);
				continue;
			}

			[_objects addObject: method_str];
		}
	}

	NSLog(@"meow -> total colors found %lu", _objects.count);

	self.title = @"UIColor color list";
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = _objects[indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	NSLog(@"meow => indexPath %@ indexRow %lu colorName %@", indexPath, indexPath.row, _objects[indexPath.row]);

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		NSString *colorName = _objects[indexPath.row];
		UIColor *color = [UIColor performSelector:NSSelectorFromString(colorName)];

		UIColorWell *well = [[UIColorWell alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, 1.0)];
		well.selectedColor = color;
		well.title = colorName;
		well.supportsAlpha = YES;
		well.center = cell.accessoryView.center;

		cell.accessoryView = well;
		cell.textLabel.text = colorName;
	}

	return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UIColor *color = [UIColor performSelector:NSSelectorFromString(_objects[indexPath.row])];
	CIColor *cicolor = [CIColor colorWithCGColor:color.CGColor];
	NSString *hexString = [NSString stringWithFormat:@"#%02X%02X%02X%02X",
		 (int)(cicolor.red*255),
		 (int)(cicolor.green*255),
		 (int)(cicolor.blue*255),
		 (int)(cicolor.alpha*255)
	];
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:_objects[indexPath.row] 
								       message:hexString
								preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
	[alert addAction:action];
	[self presentViewController:alert animated:YES completion:nil];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
