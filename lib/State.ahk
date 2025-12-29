; ========================== 状态机核心框架 ==========================
; 状态基类：所有具体状态需继承此类，实现核心行为
class State {
    Name := ""  ; 状态唯一标识名

    /**
     * 构造函数
     * @param {string} name - 状态名称（唯一）
     */
    __New(name) {
        this.Name := name
    }

    /**
     * 进入状态时执行的动作（子类重写）
     * @param  {...any} params - 自定义参数
     */
    Enter(params*) {
    }

    /**
     * 退出状态时执行的动作（子类重写）
     * @param  {...any} params - 自定义参数
     */
    Exit(params*) {
    }

    /**
     * 处理事件并返回目标状态（子类重写）
     * @param {string/object} event - 事件标识（字符串/事件对象）
     * @param  {...any} params - 自定义参数
     * @return {string} 目标状态名（空字符串表示不切换状态）
     */
    HandleEvent(event, params*) {
        return ""
    }
}

; 状态机管理类：负责状态注册、状态切换、事件触发
class StateMachine {
    CurrentState := ""       ; 当前状态名
    States := Map()          ; 已注册的状态集合（键：状态名，值：State实例）
    OnStateChange := Func("") ; 状态切换回调（可选）

    /**
     * 注册状态（重复注册会覆盖）
     * @param {State} state - 状态实例
     * @throws {Error} 非State实例时抛出错误
     */
    AddState(state) {
        if !(state is State)
            throw Error("注册失败：必须传入 State 类的实例")
        this.States[state.Name] := state
    }

    /**
     * 设置初始状态并执行进入动作
     * @param {string} stateName - 状态名
     * @throws {Error} 状态未注册时抛出错误
     */
    SetInitialState(stateName) {
        if !this.States.Has(stateName)
            throw Error("初始状态无效：" stateName " 未注册")

        this.CurrentState := stateName
        this.States[stateName].Enter()
        this._OnStateChange("", stateName) ; 触发状态切换回调
    }

    /**
     * 切换状态（内部调用，自动执行退出/进入动作）
     * @param {string} newStateName - 目标状态名
     * @param  {...any} params - 传递给Exit/Enter的参数
     * @throws {Error} 目标状态未注册时抛出错误
     */
    ChangeState(newStateName, params*) {
        if !this.States.Has(newStateName)
            throw Error("切换失败：" newStateName " 未注册")

        ; 执行当前状态的退出动作
        if (this.CurrentState != "") {
            this.States[this.CurrentState].Exit(params*)
        }

        ; 记录旧状态，更新当前状态
        local oldState := this.CurrentState
        this.CurrentState := newStateName

        ; 执行新状态的进入动作
        this.States[newStateName].Enter(params*)
        this._OnStateChange(oldState, newStateName) ; 触发状态切换回调
    }

    /**
     * 触发事件，由当前状态处理并决定是否切换状态
     * @param {string/object} event - 事件标识
     * @param  {...any} params - 传递给HandleEvent的参数
     * @throws {Error} 未设置初始状态时抛出错误
     */
    TriggerEvent(event, params*) {
        if (this.CurrentState == "")
            throw Error("触发事件失败：未设置初始状态")

        ; 获取当前状态处理事件后的目标状态
        local targetState := this.States[this.CurrentState].HandleEvent(event, params*)

        ; 目标状态有效且与当前状态不同时，执行切换
        if (targetState != "" && targetState != this.CurrentState)
            this.ChangeState(targetState, params*)
    }

    /**
     * 获取当前状态名
     * @return {string} 当前状态名
     */
    GetCurrentState() {
        return this.CurrentState
    }

    /**
     * 状态切换回调（私有方法，可通过OnStateChange自定义逻辑）
     * @param {string} oldState - 旧状态名
     * @param {string} newState - 新状态名
     */
    _OnStateChange(oldState, newState) {
        if (this.OnStateChange is Func)
            this.OnStateChange.Call(oldState, newState)
    }
}