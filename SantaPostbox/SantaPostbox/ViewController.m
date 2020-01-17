//Copyright © 2019 Extole. All rights reserved.

#import "ViewController.h"
#import "CustomNetwork.h"
@import ExtoleKit;

@interface ViewController () <ExtoleAppDelegate>
@property ExtoleApp *app;
@property UILabel *label;
@property UITextField* code;
@property UIButton* load;
@property ProgramSession* extoleSession;
@property UILabel *wishItem;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    _label = [[UILabel alloc] init];
    [[self view] addSubview:_label];
    _label.translatesAutoresizingMaskIntoConstraints = false;
    
    [[NSLayoutConstraint constraintWithItem:_label
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                 toItem: self.view.safeAreaLayoutGuide
                                 attribute: NSLayoutAttributeTop
                                 multiplier: 1
                                 constant: 1 ] setActive:true];
   
    [_label setText:(@"Loading....")];
    
    _code = [[UITextField alloc] init];
    [[self view] addSubview:_code];
    _code.translatesAutoresizingMaskIntoConstraints = false;
    [[NSLayoutConstraint constraintWithItem:_code
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                     toItem: _label
                                  attribute: NSLayoutAttributeBottom
                                 multiplier: 1
                                   constant: 0 ] setActive:true];
    
    [_code setPlaceholder:@"Enter Code"];
    
    _load = [[UIButton alloc] init];
    [[self view] addSubview:_load];
    _load.translatesAutoresizingMaskIntoConstraints = false;
    [[NSLayoutConstraint constraintWithItem:_load
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                     toItem: _code
                                  attribute: NSLayoutAttributeBottom
                                 multiplier: 1
                                   constant: 0 ] setActive:true];
    
    [_load setBackgroundColor:UIColor.blueColor];
    
    [_load setTitle: @"See" forState: UIControlStateNormal];
    [_load addTarget:self action:@selector(loadClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _wishItem = [[UILabel alloc] init];
    [[self view] addSubview:_wishItem];
    _wishItem.translatesAutoresizingMaskIntoConstraints = false;
    
    [[NSLayoutConstraint constraintWithItem:_wishItem
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                     toItem: _load
                                  attribute: NSLayoutAttributeBottom
                                 multiplier: 1
                                   constant: 1 ] setActive:true];
    [_wishItem setText:@"(enter code)"];
    
    [_label setText:(@"Loading....")];
    
    _app = ExtoleApp.alloc;
    NSURL *programUrl = [[NSURL alloc] initWithString:(@"https://ios-santa.extole.io")];
    CustomNetwork* executor = [[CustomNetwork alloc] init];
    Network* network = [[Network alloc] initWithExecutor:executor];
    Program *program = [[RequestContext alloc] initWithBaseUrl:programUrl network:network];
    _app = [[ExtoleApp alloc] initWith:program delegate:self];
    [_app activate];
}


- (void)extoleAppInvalid {
    _extoleSession = nil;
}

- (void)extoleAppReadyWithSession:(ProgramSession * _Nonnull)session {
    _extoleSession = session;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_label setText:(session.accessToken)];
    });
}

- (void)displayWishList: (MyShareable* )shareable {
    [_wishItem setText:shareable.data.allKeys.firstObject];
}

-(void)loadClicked {
    NSString *code = _code.text;
    NSString *message = @"Loading ";
    
    [self->_label setText:[message stringByAppendingString:code]];
    
    [_extoleSession getShareableWithCode:code success:^(MyShareable * shareable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayWishList: shareable];
        });
    } error:^(ExtoleError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_label setText:[message stringByAppendingString:error.code]];
        });
    }];
}

@end
