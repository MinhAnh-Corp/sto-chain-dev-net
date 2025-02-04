package keeper

import (
	"stochain/x/tokenfactory/types"
)

var _ types.QueryServer = Keeper{}
