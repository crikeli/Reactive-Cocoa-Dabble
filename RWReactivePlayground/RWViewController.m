//
//  RWViewController.m
//  Reactive Cocoa Example
//
//  Created by Kelin Christi on 21/02/2016.
//  Copyright (c) 2016 Kelz. All rights reserved.
//

#import "RWViewController.h"
#import "RWDummySignInService.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RWViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *signInFailureText;

//@property (nonatomic) BOOL passwordIsValid;
//@property (nonatomic) BOOL usernameIsValid;
@property (strong, nonatomic) RWDummySignInService *signInService;

@end

@implementation RWViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //[self updateUIState];
  
  self.signInService = [RWDummySignInService new];
  
  // handle text changes for both text fields
//  [self.usernameTextField addTarget:self action:@selector(usernameTextFieldChanged) forControlEvents:UIControlEventEditingChanged];
//  [self.passwordTextField addTarget:self action:@selector(passwordTextFieldChanged) forControlEvents:UIControlEventEditingChanged];
  
  // initially hide the failure message
  self.signInFailureText.hidden = YES;
    
    //This is done only using signal & blocks
    //Reactive Cocoa signals are represednted using RACSignal
    //rac_textSignal is the initial source of events
//    RACSignal *usernameSourceSignal =
//    self.usernameTextField.rac_textSignal;
//    
//    //data flows through a filter that only allows events to pass if it is a string with a length greater than 3.
//    RACSignal *filreredUsername = [usernameSourceSignal filter: ^BOOL(id value){
//        NSString *text = value;
//        return text.length > 3;
//    }];
//    
//    //Final step is the subscribeNext; where block logs the event.
//    [filreredUsername subscribeNext:^(id x){
//        NSLog(@"%@", x);
//    }];
    
    //Fluent Syntax.
    //A map operation is used to transform received data into anything, as long it is an object.
    [[[self.usernameTextField.rac_textSignal
      map:^id(NSString *text){
          return @(text.length);
      }]
      filter:^BOOL(NSNumber *length){
          //NSString * text = value; //implicit cast
          return [length integerValue] > 3;
      }]
     //This is where the block logs the event value.
     subscribeNext:^(id x){
         NSLog(@"%@", x);
     }];
    
    //The code below applies a map transform to the rac_textSignal from each text field.
    //the output is a bool packed as an nsnumber.
    RACSignal *validUsernameSignal =
    [self.usernameTextField.rac_textSignal
     map:^id(NSString *text) {
         return @([self isValidUsername:text]);
     }];
    
    RACSignal *validPasswordSignal =
    [self.passwordTextField.rac_textSignal
     map:^id(NSString *text) {
         return @([self isValidPassword:text]);
     }];
    
    //The RAC Macro allows one to assign the output of a signal property of an object.
    //It takes in 2 arguments; the property to set(passwordTextField) and the property name(backgroundColor)
    RAC(self.passwordTextField, backgroundColor) =
        [validPasswordSignal
         map:^id(NSNumber *passwordValid){
             return [passwordValid boolValue]? [UIColor clearColor] : [UIColor yellowColor];
         }];
    RAC(self.usernameTextField, backgroundColor) =
    [validUsernameSignal
     map:^id(NSNumber *passwordValid){
         return [passwordValid boolValue]? [UIColor clearColor] : [UIColor yellowColor];
     }];
    
    //Code below uses combineLatest:reduce method to combine the latest values emited by validUsernameSignal and validPasswordSignal into a new signal
    RACSignal *signUpActiveSignal =
    [RACSignal combineLatest:@[validUsernameSignal, validPasswordSignal]
     //Each time either of the 2 source signals emit a new value,the reduce block executes and the value it returns is sent as the next value of the combined signal
                      reduce:^id(NSNumber *usernameValid, NSNumber *passwordValid){
                          return @([usernameValid boolValue] && [passwordValid boolValue]);
                      }];
    
    [signUpActiveSignal subscribeNext:^(NSNumber *signupActive){
        self.signInButton.enabled = [signupActive boolValue];
    }];
    
    //The reactive implementation of button touch event.
    [[[[self.signInButton
        rac_signalForControlEvents:UIControlEventTouchUpInside]
       //doNext is a "side-effect" that does not return a value. It leaves the event unchanged.
       //It sets the button enabled property to NO and hides the failure text.
       doNext:^(id x){
           self.signInButton.enabled = NO;
           self.signInFailureText.hidden = YES;
       }]
     //The flattenmap method is used to send events from an inner signal to the outer signal.
     flattenMap:^id(id x){
         return[self signInSignal];
    }]
     //The subscribeNext plock has been passed a signal, the not the result of the sign-in signal.
    subscribeNext: ^(NSNumber *signedIn){
        BOOL success = [signedIn boolValue];
        self.signInFailureText.hidden = success;
        if(success){
            [self performSegueWithIdentifier:@"signInSuccess" sender:self];
        }
        //NSLog(@"Sign in result: %@", x);
    }];
}

- (BOOL)isValidUsername:(NSString *)username {
  return username.length > 3;
}

- (BOOL)isValidPassword:(NSString *)password {
  return password.length > 3;
}

//Reactive Cocoa Implementation of signInButtonTouched:
-(RACSignal *)signInSignal {
    //The createSignal: method is used on RACSignal for signal creation.
    //Whenever the signal has a subscriber, the code within the block executes.
    //the block is passed a single subscriber instance that adopts RACSubscriber protocol which has methods you invoke in order to emit events.
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
        [self.signInService
         signInWithUsername: self.usernameTextField.text password: self.passwordTextField.text complete:^(BOOL success){
             //A single next event is sent to indicate whether the sign-in was a success.
             [subscriber sendNext:@(success)];
             //Followed by a "complete" event.
             [subscriber sendCompleted];
         }];
        return nil;
    }];
}


//signInButtonTouched method:
//- (IBAction)signInButtonTouched:(id)sender {
//  // disable all UI controls
//  self.signInButton.enabled = NO;
//  self.signInFailureText.hidden = YES;
//  
//  // sign in
//  [self.signInService signInWithUsername:self.usernameTextField.text
//                            password:self.passwordTextField.text
//                            complete:^(BOOL success) {
//                              self.signInButton.enabled = YES;
//                              self.signInFailureText.hidden = success;
//                              if (success) {
//                                [self performSegueWithIdentifier:@"signInSuccess" sender:self];
//                              }
//                            }];
//}


// updates the enabled state and style of the text fields based on whether the current username
// and password combo is valid
//- (void)updateUIState {
////  self.usernameTextField.backgroundColor = self.usernameIsValid ? [UIColor clearColor] : [UIColor yellowColor];
////  self.passwordTextField.backgroundColor = self.passwordIsValid ? [UIColor clearColor] : [UIColor yellowColor];
//  self.signInButton.enabled = self.usernameIsValid && self.passwordIsValid;
//}
//
//- (void)usernameTextFieldChanged {
//  self.usernameIsValid = [self isValidUsername:self.usernameTextField.text];
//  [self updateUIState];
//}
//
//- (void)passwordTextFieldChanged {
//  self.passwordIsValid = [self isValidPassword:self.passwordTextField.text];
//  [self updateUIState];
//}

@end
