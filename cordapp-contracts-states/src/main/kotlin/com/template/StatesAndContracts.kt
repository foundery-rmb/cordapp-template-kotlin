package com.template

import net.corda.core.contracts.*
import net.corda.core.identity.AbstractParty
import net.corda.core.identity.Party
import net.corda.core.serialization.DeprecatedConstructorForDeserialization
import net.corda.core.transactions.LedgerTransaction

// *****************
// * Contract Code *
// *****************
// This is used to identify our contract when building a transaction
val TEMPLATE_CONTRACT_ID = "com.template.TemplateContract"

open class TemplateContract : Contract {
    // A transaction is considered valid if the verify() function of the contract of each of the transaction's input
    // and output states does not throw an exception.
    override fun verify(tx: LedgerTransaction) {
        val command = tx.commands.requireSingleCommand<Commands.Action>()

        requireThat {
            // Constraints on the shape of the transaction.
            "No inputs should be consumed when issuing an IOU." using (tx.inputs.isEmpty())
            "There should be one output state." using (tx.outputs.size == 1)

            // IOU-specific constraints.
            val out = tx.outputsOfType<TemplateState>().single()
            "Data contains ą." using (out.data.contains("ą"))
            "The me and them are different." using (out.me != out.them)

            // Constraints on the signers.
            "There must be two signers." using (command.signers.toSet().size == 2)
            "The borrower and lender must be signers." using (command.signers.containsAll(listOf(
                    out.me.owningKey, out.them.owningKey)))
        }
    }

    // Used to indicate the transaction's intent.
    interface Commands : CommandData {
        class Action : Commands
    }
}

// *********
// * State *
// *********

// OLD STATE
data class TemplateState(val data: String, val me: Party, val them: Party) : ContractState {
    override val participants: List<AbstractParty> get() = listOf(me, them)
}


// NEW STATE
//data class TemplateState(val data: String, val me: Party, val them: Party, val extraData:String) : ContractState {
//
//    @DeprecatedConstructorForDeserialization(1)
//    constructor (data: String, me: Party, them: Party) : this(data, me, them, "bambam")
//
//    override val participants: List<AbstractParty> get() = listOf(me, them)
//}