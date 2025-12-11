class BTreeNode {
    __New(isLeaf := true) {
        this.keys := []  ; 存储键
        this.values := []  ; 存储对应替换值
        this.children := []  ; 子节点引用
        this.isLeaf := isLeaf  ; 是否为叶节点
    }
}

class BTree {
    __New(minDegree := 3) {
        this.root := BTreeNode()
        this.minDegree := minDegree  ; B树的最小度数
    }

    ; 插入键值对
    Insert(key, value) {
        root := this.root
        if (root.keys.Length = 2 * this.minDegree - 1) {
            newNode := BTreeNode(false)
            this.root := newNode
            newNode.children.Push(root)
            this.SplitChild(newNode, 1)
            this.InsertNonFull(newNode, key, value)
        } else {
            this.InsertNonFull(root, key, value)
        }
    }

    ; 分裂子节点
    SplitChild(parent, index) {
        minDegree := this.minDegree
        child := parent.children[index]
        newChild := BTreeNode(child.isLeaf)

        ; 复制后半部分键值对
        newChild.keys := child.keys.Slice(minDegree, 2 * minDegree - 1)
        newChild.values := child.values.Slice(minDegree, 2 * minDegree - 1)

        ; 复制子节点（非叶节点时）
        if (!child.isLeaf) {
            newChild.children := child.children.Slice(minDegree, 2 * minDegree)
        }

        ; 调整原节点大小（保留前minDegree-1个元素）
        child.keys := child.keys.Slice(1, minDegree - 1)
        child.values := child.values.Slice(1, minDegree - 1)

        ; 插入新子节点（在index后插入）
        parent.children.InsertAt(index + 1, newChild)
        parent.keys.InsertAt(index, child.keys[minDegree - 1])  ; 中间元素上移
        parent.values.InsertAt(index, child.values[minDegree - 1])
    }

    ; 非满节点插入
    InsertNonFull(node, key, value) {
        i := node.keys.Length  ; 从最后一个元素开始
        if (node.isLeaf) {
            ; 叶节点直接插入（从后向前查找位置）
            while (i > 1 && StrCompare(key, node.keys[i - 1]) < 0) {
                node.keys[i] := node.keys[i - 1]
                node.values[i] := node.values[i - 1]
                i--
            }
            node.keys.Push(key)
            node.values.Push(value)
        } else {
            ; 内部节点查找子节点
            while (i > 1 && StrCompare(key, node.keys[i - 1]) < 0) {
                i--
            }
            i++  ; 修正：子节点索引=键索引+1
            child := node.children[i]
            if (child.keys.Length = 2 * this.minDegree - 1) {
                this.SplitChild(node, i)
                if (StrCompare(key, node.keys[i]) > 0) {
                    i++
                    child := node.children[i]
                }
            }
            this.InsertNonFull(child, key, value)
        }
    }

    ; 查找最长匹配键（修正字符串索引）
    FindLongestMatch(str, startPos) {
        current := this.root
        matchLength := 0
        matchValue := ""
        currentPos := startPos

        while (true) {
            i := 1
            found := false
            ; 在当前节点查找匹配键
            while (i <= current.keys.Length) {
                key := current.keys[i]
                keyLen := StrLen(key)
                ; 检查剩余字符串是否足够匹配
                if (currentPos + keyLen - 1 > StrLen(str)) {
                    i++
                    continue
                }
                ; 提取子串比较（SubStr第3个参数是长度）
                sub := SubStr(str, currentPos, keyLen)
                if (sub = key && keyLen > matchLength) {
                    matchLength := keyLen
                    matchValue := current.values[i]
                    found := true
                    break  ; 找到最长匹配后跳出
                }
                i++
            }

            if (found || current.isLeaf) {
                break  ; 叶节点或找到匹配时停止
            }

            ; 进入子节点继续查找
            nextChar := SubStr(str, currentPos + matchLength, 1)
            i := 1
            while (i <= current.keys.Length && StrCompare(nextChar, current.keys[i]) > 0) {
                i++
            }
            current := current.children[i]
            currentPos += matchLength
        }

        return { length: matchLength, value: matchValue }
    }
}

/**
 * 基于B树的批量替换类
 */
class BTreeReplacer {
    index := BTree()
    __New(replaceTexts*) {
        ; 构建B树索引
        for key, value in Map(replaceTexts*) {
            this.index.Insert(key, value)
        }
    }
    /**
     * 基于B树的批量替换函数
     * @param {String} str 待替换的字符串
     * @param {Map} replaceTexts 替换规则，键为待替换文本，值为替换文本
     * @returns {String} 替换后的字符串
     * @example
     * replacer := BTreeReplacer("涅樂", "涅槃", "錯別字", "错别字", "測試", "测试")
     * originalStr := "这是一个測試，包含涅樂和錯別字的文本。"
     * resultStr := replacer.replace(originalStr, replaceMap)
     * MsgBox(resultStr)  ; 输出："这是一个测试，包含涅槃和错别字的文本。"
     */
    replace(str) {
        result := ""
        currentPos := 1
        len := StrLen(str)

        while (currentPos <= len) {
            ; 查找最长匹配
            match := this.index.FindLongestMatch(str, currentPos)
            if (match.length > 0) {
                result .= match.value
                currentPos += match.length
            } else {
                ; 无匹配则复制当前字符
                result .= SubStr(str, currentPos, 1)
                currentPos++
            }
        }

        return result
    }
}