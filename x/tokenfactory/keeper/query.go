package keeper

import (
	"stocchain/x/tokenfactory/types"
)

var _ types.QueryServer = Keeper{}
