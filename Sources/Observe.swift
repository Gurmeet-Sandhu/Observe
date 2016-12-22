struct Observe {

//    var text = "Hello, World!"
//    
//    static var failureHandler: ((_ message: String, _ file: StaticString, _ line: UInt) -> (Void))?
//    static var successHandler: ((_ message: String, _ file: StaticString, _ line: UInt) -> (Void))?
//    
    
    static var currentTest: ObserveTestable?
    
    static func runTests() {
        guard let currentTest = currentTest else {
            // No more tests to run
            return
        }
        
        guard currentTest.running == false else {
            // Already Running
            return
        }
        
        if currentTest.tested == false {
            currentTest.runTest()
            
            // TODO: Run the before, not before each, here
        }
        
        self.currentTest = nextTestInLine()
        
        
        runTests()
    }
    
    /**
     Get the next child test in line and remove it from the line.
     If there are no more children tests, return the parent test.
     If there is a child test, run the `beforeEach()` method before returning.
    */
    private static func nextTestInLine() -> ObserveTestable? {
        var test: ObserveTestable?
        
        if let nextChild = currentTest?.popNextChild() {
            test = nextChild
            currentTest?.runBeforeEachChild()
        } else {
            test = currentTest?.parent
        }
        
        return test
    }
}

func describe(_ message: String, file: StaticString = #file, line: UInt = #line, handler: @escaping ((Void) -> (Void))) {
    let test = ObserveTest()
    test.closure = handler
    test.description = message
    
    if var currentTest = Observe.currentTest {
        currentTest.addChild(test: test)
    } else {
        Observe.currentTest = test
    }
//    print("✏️ \(message)")
    Observe.runTests()
}


/**
 Called before each of the blocks within the same scope.
 */
func beforeEach(file: StaticString = #file, line: UInt = #line, handler: @escaping ((Void) -> (Void))) {
    guard var currentTest = Observe.currentTest else {
        print("🖕🏼Error: beforeEach must go inside a function")
        return
    }
    
    currentTest.beforeEachChild = handler
}

