module rui::board {
    use sui::package;
    use sui::tx_context::sender;
    use sui::event;
    use std::string::String;
    
    use rui::semaphore;

    public struct BOARD has drop {}

    public struct QA has key, store {
        id: UID,
        question: String,
        answers: vector<vector<u8>>,
    }

    public struct CreateQAEvent has copy, drop {
        id: ID,
    }

    public struct AddAnswerEvent has copy, drop {
        id: ID,
        answer: vector<u8>,
    }

    fun init(witness: BOARD, ctx: &mut TxContext) {
        let publisher = package::claim(witness, ctx);
        transfer::public_transfer(publisher, sender(ctx));
    }

    entry fun create_qa(question: String, ctx: &mut TxContext) {
        let qa = QA {
            id: object::new(ctx),
            question,
            answers: vector::empty(),
        };

        event::emit(CreateQAEvent {
            id: object::uid_to_inner(&qa.id),
        });
        
        transfer::transfer(qa, sender(ctx));
    }

    entry fun add_answer(verifying_key: vector<u8>, proof_points: vector<u8>, public_inputs: vector<u8>, qa: &mut QA, answer: vector<u8>, _ctx: &mut TxContext) {
        assert!(semaphore::verify_proof(verifying_key, proof_points, public_inputs));

        vector::push_back<vector<u8>>(&mut qa.answers, answer);

        event::emit(AddAnswerEvent {
            id: object::uid_to_inner(&qa.id),
            answer,
        });
    }
}