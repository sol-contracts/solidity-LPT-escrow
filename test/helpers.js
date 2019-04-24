const getLog = (receipt, logName, argName) => {
    const log = receipt.logs.find(({ event }) => event == logName)
    return log ? log.args[argName] : null
}

const assertEqualBN = async (actualPromise, expected, message) =>
    assert.equal((await actualPromise).toNumber(), expected, message)

const assertRevert = async (receiptPromise, reason) => {
    try {
        await receiptPromise
    } catch (e) {
        if (reason) {
            assert.include(e.message, reason, 'Incorrect revert reason')
        }
        return
    }
    assert.fail(`Expected a revert for reason: ${reason}`)
}

module.exports = {
    getLog: getLog,
    assertEqualBN: assertEqualBN,
    assertRevert: assertRevert
}