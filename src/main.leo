// The token debit function
function debit(
    token_debit: [u8; 48],
    token_credit: [u8; 48]
) -> (u8, u8) {
    // 1. Check token ids match
    let id_t: u8 = input.registers.token_id;
    let payload: [u8; 32] = input.record.payload;
    let payload_id_t: u8 = payload[0]; // payload is u8 bytes
    let condition1: bool = id_t == payload_id_t;

    // 2. Check record death is token_debit
    let id_d: [u8; 48] = input.record.death_program_id;
    let condition2: bool = id_d == token_debit;

    // 3. Check record birth is token_credit
    let id_b: [u8; 48] = input.record.birth_program_id;
    let condition3: bool = id_b == token_credit;

    // 4. Handle old_record_0 new token case
    let global_index: u32 = input.state.leaf_index;
    let vb_t_old: u8 = input.registers.value_balance;
    let is_zero: bool = vb_t_old == 0;
    let condition4: bool = global_index == 0 ? is_zero : true;

    // 5. Add payload value to register value balance
    let payload_vb_t: u8 = payload[1];
    let vb_t_new: u8 = vb_t_old + payload_vb_t;

    // 6. Debit the funds if checks pass
    let passed: bool = condition1 && condition2 && condition3 && condition4;

    if passed {
        return (id_t, vb_t_new);
    } else {
        return (id_t, vb_t_old);
    }
}

// The token credit function
function credit(
    token_credit: [u8; 48]
) -> (u8, u8) {
    let id_t = input.registers.token_id;
    let payload: [u8; 32] = input.record.payload;
    let payload_id_t: u8 = payload[0];

    // 1. Check token id's match
    let condition1: bool = id_t == payload_id_t;

    // 2. Check record birth
    let id_b: [u8; 48] = input.record.birth_program_id;
    let condition2: bool = id_b == token_credit;

    // 3. Subtract payload value form register value balance
    let vb_t_old: u8 = input.registers.value_balance;
    let payload_vb_t: u8 = payload[1];
    let vb_t_new: u8 = vb_t_old - payload_vb_t;

    // 4. Check that no money is created
    let condition3: bool = vb_t_new <= vb_t_old;

    // 5. Handle new_record_1 value is conserved case
    let global_index: u32 = input.state.leaf_index;
    let is_zero: bool = vb_t_new == 0;
    let condition4: bool = global_index == 3 ? is_zero : true;

    // 6. Credit the funds if checks pass
    let passed: bool = condition1 && condition2 && condition3 && condition4;

    if passed {
        return (id_t, vb_t_new);
    } else {
        return (id_t, vb_t_old);
    }
}

// // The 'token' debit main function.
// function main() -> (u8, u8) {

//     // Set by token factory instance.
//     let token_credit: [u8; 48] = [1; 48];
//     let token_debit: [u8; 48] = [0; 48];

//     return debit(token_debit, token_credit);
// }

// // The 'token' credit main function.
// function main() -> (u8, u8) {

//     // Set by token factory instance.
//     let token_credit: [u8; 48] = [1; 48];
//     //let token_debit: [u8; 48] = [0; 48]; // not used

//     return credit(token_credit);
// }
