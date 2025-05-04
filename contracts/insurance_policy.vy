
sinister_occured: public(bool) # Event that triggers insurance coverage
endtime: public(uint256)       # Time that determines the end of the policy's validity (sec.)    

insurance_company: address     # Address of the insurer
insured : address              # Address of the insured

premium: public(uint256)       # Amount paid for insurance
sinister: public(uint256)      # Value of the sinister 

premium_deposited: bool 
sinister_deposited: bool 

@deploy
def __init__(premium: uint256, sinister: uint256, time_window: uint256):
    self.sinister_occured = False
    self.endtime =  block.timestamp + time_window

    self.premium = premium 
    self.sinister = sinister

    self.premium_deposited = False 
    self.sinister_deposited = False 

    self.insurance_company = msg.sender

@external
@payable
def deposit_collateral():
    assert self.sinister_occured == False, "An accident has occurred, policy has ended"
    assert msg.sender == self.insurance_company, "Only the insurer can deposit"
    assert self.endtime > block.timestamp, "The collateral deposit can only be made until the policy has ended"
    assert msg.value == self.sinister, "Deposited amount is different from the expected claim amount"
    assert self.sinister_deposited == False, "Collateral deposit has already been made by the insurer"

    self.sinister_deposited = True

@external
@payable
def withdraw_collateral():
    assert self.sinister_occured == False, "An accident has occurred, policy has ended"
    assert msg.sender == self.insurance_company, "Only the insurer can withdraw collateral"
    assert self.endtime < block.timestamp, "Collateral can only be withdrawn after the end of the policy"
    assert self.sinister_deposited == True, "No collateral deposit has been made"

    send(msg.sender, self.sinister)
    self.sinister_deposited = False

@external
@payable
def deposit_premium():
    assert self.sinister_occured == False, "An accident has occurred, policy has ended"
    assert msg.sender != self.insurance_company, "The insurer cannot deposit the premium"
    assert self.endtime > block.timestamp, "The premium deposit can only be made until the policy has ended"
    assert msg.value == self.premium, "Deposited amount is different from the expected premium amount"
    assert self.premium_deposited == False, "Premium deposit has already been made by the insured"

    self.insured = msg.sender
    self.premium_deposited = True

@external
@payable
def withdraw_premium():
    assert self.sinister_occured == False, "An accident has occurred, policy has ended"
    assert msg.sender == self.insurance_company, "Only the insurer can withdraw premium"
    assert self.endtime < block.timestamp, "Premium can only be withdrawn after the end of the policy"
    assert self.premium_deposited == True, "No premium deposit has been made"

    send(msg.sender, self.premium)
    self.premium_deposited = False

@external
@payable
def accident_happens():
    assert self.sinister_occured == False, "An accident has occurred, policy has ended"
    assert msg.sender == self.insurance_company, "Only the insurer can trigger the sinister"
    assert self.endtime > block.timestamp, "The sinister can only happened until the policy has ended"
    assert self.sinister_deposited == True, "No sinister deposit has been made"
    assert self.premium_deposited == True, "No premium deposit has been made"
    
    self.sinister_occured = True
    send(self.insured, self.sinister)
