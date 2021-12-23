# TODO-MVI-RxSwift-Swift

### Contributors

[Benoît Quenaudon](https://github.com/oldergod)

### Summary

This version of the app is called TODO-MVI-RxSwift-Swift. It is based on an Android ported version of the Model-View-Intent architecture and uses RxSwift to implement the reactive characteristic of the architecture. 

The MVI architecture embraces reactive and functional programming. The two main components of this architecture, the _View_ and the _ViewModel_ can be seen as functions, taking an input and emiting outputs to each other. The _View_ takes input from the _ViewModel_ and emit back _intents_. The _ViewModel_ takes input from the _View_ and emit back _view states_. This means the _View_ has only one entry point to forward data to the _ViewModel_ and vice-versa, the _ViewModel_ only has one way to pass information to the _View_.  
This is reflected in their API. For instance, The _View_ has only two exposed methods:

```swift
protocol MviView {
  func intents() -> Observable<MviIntent>

  func render(state: MviViewState)
}
```

A _View_ will a) emit its intents to a _ViewModel_, and b) subscribes to this _ViewModel_ in order to receive _states_ needed to render its own UI.

A _ViewModel_ exposes only two methods as well:

```swift
protocol MviViewModel {
  func processIntents(intents: Observable<MviIntent>)

  func states() -> Observable<MviViewState>
}
```

A _ViewModel_ will a) process the _intents_ of the _View_, and b) emit a _view state_ back so the _View_ can reflect the change, if any.

<img src="https://raw.githubusercontent.com/oldergod/android-architecture/todo-mvi-rxjava-kotlin/art/MVI_global.png" alt="View and ViewModel are simple functions."/>

### The User is a function

The MVI architecture sees the user as part of the data flow, a functional component taking input from the previous one and emitting event to the next. The user receives an input―the screen from the application―and outputs back events (touch, click, scroll...). On Android, the input/output of the UI is at the same place; either physically as everything goes through the screen or in the program: I/O inside the activity or the fragment. Including the User to seperate the input of the view from its output helps keeping the code healty.

<img src="https://raw.githubusercontent.com/oldergod/android-architecture/todo-mvi-rxjava-kotlin/art/MVI_detail.png" alt="Model-View-Intent architecture in details"/>

### MVI in details

We saw what the _View_ and the _ViewModel_ were designed for, let's see every part of the data flow in details.

#### Intent

_Intents_ represents, as their name goes, _intents_ from the user, this goes from opening the screen, clicking a button, or reaching the bottom of a scrollable list.

#### Action from Intent

_Intents_ are in this step translated into their respecting logic _Action_. For instance, inside the tasks module, the "opening the view" intent translates into "refresh the cache and load the data". The _intent_ and the translated _action_ are often similar but this is important to avoid the data flow to be too coupled with the UI. It also allows reuse of the same _action_ for multiple different _intents_.

#### Action

_Actions_ defines the logic that should be executed by the _Processor_.

#### Processor

_Processor_ simply executes an _Action_. Inside the _ViewModel_, this is the only place where side-effects should happen: data writing, data reading, etc.

#### Result

_Results_ are the result of what have been executed inside the Processor. Their can be errors, successful execution, or "currently running" result, etc.

#### Reducer

The _Reducer_ is responsible to generate the _ViewState_ which the View will use to render itself. The _View_ should be stateless in the sense that the _ViewState_ should be sufficient for the rendering. The _Reducer_ takes the latest _ViewState_ available, apply the latest _Result_ to it and return a whole new _ViewState_.

#### ViewState

The _State_ contains all the information the _View_ needs to render itself.

### Observable

[RxSwift](https://github.com/ReactiveX/RxSwift) is used in this sample. The data model layer exposes RxSwift `Observable` streams as a way of retrieving tasks. In addition, when needed, `void` returning setter methods expose RxSwift `Completable` streams to allow composition inside the _ViewModel_.  

 The `TasksDataSource` interface contains methods like:

```swift
func getTasks() -> Single<List<Task>>

func getTask(taskId: String) -> Single<Task>

func completeTask(task: Task) -> Completable
```
### Threading

Handling of the working threads is done with the help of RxSwift's `Scheduler`s. For example, the creation of the database together with all the database queries is happening on the IO thread.

### Immutability

Data immutability is embraced to help keeping the logic simple. Immutability means that we do not need to manage data being mutated in other methods, in other threads, etc; because we are sure the data cannot change. Data immutability is implemented with Swift's `enum`.

### Functional Programming

Threading and data mutability is one easy way to shoot oneself in the foot. In this sample, pure functions are used as much as possible. Once an _Intent_ is emitted by the _View_, up until the _ViewModel_ actually access the repository, 1) all objects are immutable, and 2) all methods are pure (side-effect free and idempotent). The same goes on the way back. Side effects should be restrained as much as possible.

### Dependencies

* [RxSwift](https://github.com/ReactiveX/RxSwift)

## Features

### Complexity - understandability

#### Use of architectural frameworks/libraries/tools:

Building an app following the MVI architecture is not trivial as it uses new concepts from reactive and functional programming.

#### Conceptual complexity

Developers need to be familiar with the observable pattern and functional programming.

### Maintainability

#### Ease of amending or adding a feature

High. Side effects are restrained and since every part of the architecture has a well defined purpose, adding a feature is only a matter of creating a new isolated processor and plug it into the existing stream.

#### Learning cost

Medium as reactive and functional programming, as well as Observables are not trivial.

