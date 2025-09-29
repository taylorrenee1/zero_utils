local banking = zutils.bridge_loader("banking")
if not banking then return end

zutils.banking = {}

function zutils.banking.getBalance(cid)
    return banking.getBalance(cid)
end

function zutils.banking.getSocietyBalance(job)
    return banking.getSocietyBalance(job)
end

function zutils.banking.depositSociety(job, amount, reason, src)
    return banking.depositSociety(job, amount, reason, src)
end

function zutils.banking.withdrawSociety(job, amount, reason, src)
    return banking.withdrawSociety(job, amount, reason, src)
end

return zutils.banking
